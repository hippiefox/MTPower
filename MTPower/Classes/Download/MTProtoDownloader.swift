

import Foundation
import SJMediaCacheServer

public protocol MTDownloadProvider: NSObject {
    var allTasks: [MTDownloadTask] { get }
    var ingTasks: [MTDownloadTask] { get }
    var failedTasks: [MTDownloadTask] { get }
    var completedTasks: [MTDownloadTask] { get }

    /// dm任务更新信息
    func dmTaskUpdate(task: MTDownloadTask, speed: String, downloadedSize: Int, state: MTDownState, step: MTDMDownloadStep, averageSpeed: Int)

    ///  更新下载任务的下载信息，如url地址，header等
    func fetchRealUrl(of task: MTDownloadTask, completion: @escaping (MTDownloadTask?) -> Void)

    /// 更新task地址信息
    func taskUpdate(task: MTDownloadTask, url: String)
    /// 更新task状态信息
    func taskUpdate(task: MTDownloadTask, state: MTDownState)
    /// 更新task存储信息
    func taskUpdate(task: MTDownloadTask, speedStr: String, downloadedSize: Int)
}

public enum MTProtoDownloaderNoti: String {
    case begin
    case success
    case failed

    var notiName: String { "MTProtoDownloaderNoti_\(rawValue)" }
}

open class MTProtoDownloader: NSObject {
    public var downloadProvider: MTDownloadProvider!

    /// 暂停所有下载任务
    open func pauseAll() {
        let ingTasks = downloadProvider.ingTasks
        ingTasks.forEach { self.pause(task: $0) }
        cancelTimer()
    }

    /// 暂停某一个任务
    open func pause(task: MTDownloadTask) {
        if task.__needsFetchUrl == false,
           let receipt = MTDownloadManager.defaultInstance().downloadReceipt(forURL: task.url) {
            MTDownloadManager.defaultInstance().suspend(with: receipt)
        }
    }

    open func startAllTasks() {
        /* 将状态置为none */
        __beginDownload()
    }

    open func start(task: MTDownloadTask) {
        downloadProvider.taskUpdate(task: task, state: .none)
        __download(task: task)
    }

    open func syncTaskInfo(_ task: MTDownloadTask) {
        guard task.url.isEmpty == false,
              let receipt = MTDownloadManager.defaultInstance().downloadReceipt(forURL: task.url)
        else { return }

        downloadProvider.taskUpdate(task: task, speedStr: receipt.speed, downloadedSize: Int(receipt.totalBytesWritten))
    }

    open func delete(tasks: [MTDownloadTask]) {
        tasks.forEach {
            self.pause(task: $0)
            if $0.url.isEmpty == false,
               let receipt = MTDownloadManager.defaultInstance().downloadReceipt(forURL: $0.url) {
                receipt.failureBlock = { _, _, _ in }
                receipt.successBlock = { _, _, _ in }
                receipt.progressBlock = { _, _ in }
                MTDownloadManager.defaultInstance().remove(with: receipt)
                if $0.is_encrypted,
                   let url = URL(string: $0.url) {
                    SJMediaCacheServer.shared().removeCache(for: url)
                }
            }
        }
    }

    // MARK: /*download step*/

    open func __beginDownload() {
        guard let task = downloadProvider.ingTasks.first(where: { $0.state != .ing && $0.state != .pause && $0.state != .failed }) else { return }

        __download(task: task)
    }

    open func __download(task: MTDownloadTask) {
        guard task.isDM == false else {
            beginDMDownload()
            return
        }

        if task.__needsFetchUrl {
            downloadProvider.fetchRealUrl(of: task) { [weak self] newTask in
                if let newTask = newTask {
                    self?.__realDownload(task: newTask)
                } else {
                    NotificationCenter.default.post(name: .init(MTProtoDownloaderNoti.failed.rawValue), object: nil)
                    self?.__beginDownload()
                }
            }
        } else {
            if let receipt = MTDownloadManager.defaultInstance().downloadReceipt(forURL: task.url),
               receipt.lastState == .urlFailed {
                // 需要更新其下载地址信息
                downloadProvider.fetchRealUrl(of: task) { [weak self] newTask in
                    if let newTask = newTask {
                        MTDownloadManager.defaultInstance().update(receipt, url: newTask.url, headers: newTask.headerJSONStr)
                        self?.__realDownload(task: newTask)
                    } else {
                        self?.__beginDownload()
                        NotificationCenter.default.post(name: .init(MTProtoDownloaderNoti.failed.rawValue), object: nil)
                    }
                }
            } else {
                __realDownload(task: task)
            }
        }
    }

    open func __realDownload(task: MTDownloadTask) {
        assert(task.__needsFetchUrl == false)

        downloadProvider.taskUpdate(task: task, state: .ing)

        if task.is_encrypted,
           let taskURL = URL(string: task.url),
           let proxyURL = SJMediaCacheServer.shared().playbackURL(with: taskURL) {
            SJMediaCacheServer.shared().isEnabledConsoleLog = false
            SJMediaCacheServer.shared().logLevel = .debug
            SJMediaCacheServer.shared().logOptions = .proxyTask
            SJMediaCacheServer.shared().writeDataEncoder = { _, _, data in
                let res = MTDownloadManager.data_xor(data)
                return res
            }
            downloadProvider.taskUpdate(task: task, url: proxyURL.absoluteString)
        }

        if let receipt = MTDownloadManager.defaultInstance().downloadReceipt(forURL: task.url) {
            if receipt.state == .completed {
                __success(task: task)
                return
            }
            if receipt.state == .failed {
                __failed(task: task)
                return
            }
        }
        MTDownloadManager.defaultInstance().downloadFile(withURL: task.url, headers: task.headerJSONStr, progress: nil, destination: nil) { _, _, _ in
            self.__success(task: task)
        } failure: { req, _, _ in
            if let urlStr = req.url?.absoluteString,
               let receipt = MTDownloadManager.defaultInstance().downloadReceipt(forURL: urlStr),
               receipt.lastState == .urlFailed || receipt.lastState == .suspened {
                self.downloadProvider.taskUpdate(task: task, state: .pause)
            } else {
                self.__failed(task: task)
            }
        }

        NotificationCenter.default.post(name: .init(MTProtoDownloaderNoti.begin.rawValue), object: nil)
    }

    open func __success(task: MTDownloadTask) {
        /// realm DB去更新状态
        downloadProvider.taskUpdate(task: task, state: .success)
        NotificationCenter.default.post(name: .init(MTProtoDownloaderNoti.success.rawValue), object: nil)
        // 尝试下载下一个
        __beginDownload()
    }

    private func __failed(task: MTDownloadTask) {
        downloadProvider.taskUpdate(task: task, state: .failed)
        NotificationCenter.default.post(name: .init(MTProtoDownloaderNoti.failed.rawValue), object: nil)
        __beginDownload()
    }

    open var dmTimer: DispatchSourceTimer?
}

// MARK: /*DMDownload*/

extension MTProtoDownloader {
    @objc open func beginDMDownload() {
        let dmTasks = downloadProvider.ingTasks.filter { $0.isDM }
        guard dmTasks.isEmpty == false else {
            cancelTimer()
            return
        }

        dmTasks.forEach {
            downloadProvider.taskUpdate(task: $0, state: .ing)
        }
        cancelTimer()
        dmTimer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
        dmTimer?.schedule(deadline: .now(), repeating: .milliseconds(MTDownloaderConfig.dmDownloadRefreshDuration))
        dmTimer?.setEventHandler(handler: { [weak self] in
            self?.handleDMProgress()
        })
        dmTimer?.activate()
    }

    @objc open func handleDMProgress() {
        let dmingTasks = downloadProvider.ingTasks.filter { $0.isDM }
        guard dmingTasks.isEmpty == false else {
            cancelTimer()
            return
        }
        for task in dmingTasks {
            var speed = 0
            let fileSize = task.filesize == 0 ? 1 : task.filesize
            var downloadedSize = task.downloadedSize
            var dmStep: MTDMDownloadStep = .dming
            switch task.state {
            /// 进行中的任务
            case .ing:
                let _progress = Double(task.downloadedSize) / Double(fileSize)
                let fileSizeLeft = fileSize - downloadedSize
                speed = randomSize(from: MTDownloaderConfig.lowSpeed, to: MTDownloaderConfig.highSpeed)
                downloadedSize += speed

                if _progress >= 0.99 {
                    speed = 0
                    dmStep = .almost99
                    downloadedSize = Int(Double(task.filesize) * 0.99)
                }

                var averageSpeed: Int = task.dmAverageSpeed
                if averageSpeed == 0 {
                    averageSpeed = randomSize(from: MTDownloaderConfig.lowSpeed, to: MTDownloaderConfig.highSpeed)
                }
                let targetState: MTDownState = dmStep == .almost99 ? .pause : .ing
                let speedStr = ByteCountFormatter.string(fromByteCount: .init(speed), countStyle: .binary)
                downloadProvider.dmTaskUpdate(task: task, speed: speedStr, downloadedSize: downloadedSize, state: targetState, step: dmStep, averageSpeed: averageSpeed)
            default: break
            }
        }

        let rfTasks = dmingTasks.filter { $0.isDM && $0.state == .ing }
        if rfTasks.isEmpty {
            cancelTimer()
        }
    }

    public func cancelTimer() {
        dmTimer?.cancel()
        dmTimer = nil
    }

    public func randomSize(from: Int, to: Int) -> Int {
        let gap = abs(to - from)
        if gap == 0 { return 0 }
        let r = Int(arc4random()) % gap + min(from, to)
        return r
    }
}
