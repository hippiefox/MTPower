//
//  MTTimerManager.swift
//  MTPower
//
//  Created by PanGu on 2022/10/19.
//

import Foundation
public class MTTimerManager {
    public static let `default` = MTTimerManager()

    private var timerDic: [String: TimerItem] = [:]

    public func clearAllTimer() {
        timerDic.values.forEach { $0.ts.cancel() }
        timerDic.removeAll()
    }

    public func clearTimer(flag: String) {
        guard let timerItem = timerDic[flag] else { return }
        timerItem.ts.cancel()
        timerDic[flag] = nil
    }

    public func countDown(timerFlag: String,
                          duration: Int = 60,
                          countingBlock: ((Int)->Void)? = nil,
                          completion: (()->Void)? = nil) {
        if let timer = timerDic[timerFlag] {
            timer.ts.cancel()
        }

        let timeAtStart = Date().timeIntervalSince1970
        let ts = DispatchSource.makeTimerSource(flags: .init(rawValue: 0),
                                                queue: DispatchQueue.global())
        let timerItem = TimerItem(ts: ts, timeAtStart: timeAtStart, duration: duration)
        timerDic[timerFlag] = timerItem
        ts.schedule(deadline: .now(), repeating: .milliseconds(1000))
        ts.setEventHandler { [unowned self] in
            DispatchQueue.main.async {
                let timeNow = Date().timeIntervalSince1970
                let leftTime = duration - Int(timeNow - timeAtStart)
                if leftTime < 0 {
                    self.clearTimer(flag: timerFlag)
                    completion?()
                } else {
                    countingBlock?(leftTime)
                }
            }
        }
        ts.activate()
    }

    public func resume(timerFlag: String,
                       beginBlock: ((Int)->Void)? = nil,
                       countingBlock: ((Int)->Void)? = nil,
                       completion: (()->Void)? = nil)
    {
        guard let timerItem = timerDic[timerFlag],
              timerItem.ts.isCancelled == false
        else { return }

        let timeNow = Date().timeIntervalSince1970
        let timeAtStart = timerItem.timeAtStart
        let duration = timerItem.duration
        let leftTime = duration - Int(timeNow - timeAtStart)
        guard leftTime > 0 else{
            clearTimer(flag: timerFlag)
            return
        }
        
        beginBlock?(leftTime)
        timerItem.ts.setEventHandler {
            [unowned self] in
            DispatchQueue.main.async {
                let timeNow = Date().timeIntervalSince1970
                let leftTime = duration - Int(timeNow - timeAtStart)
                if leftTime < 0 {
                    self.clearTimer(flag: timerFlag)
                    completion?()
                } else {
                    countingBlock?(leftTime)
                }
            }
        }
    }
}

extension MTTimerManager {
    private struct TimerItem {
        let ts: DispatchSourceTimer
        let timeAtStart: TimeInterval
        let duration: Int
    }
}
