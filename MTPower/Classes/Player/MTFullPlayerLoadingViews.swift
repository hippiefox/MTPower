//
//  MTFullLoadingViews.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
//

import Foundation

public struct MTPlayerLoadingTipsViewConfig {
    public static var textColor: UIColor = .white
    public static var textFont: UIFont = UIFont.systemFont(ofSize: 12)
    public static var progressColor: UIColor = .blue
    public static var tipsCellRowHeight: CGFloat = 30
    public static var timeDuration = 30
    public static var timeCountingTips = "加载剩余时间:"
    public static var timeCountingFinishTips = "加载失败,请退出重试"
    /// 秒数
    public static var scrollInterval = 3
}

public class MTFullPlayerLoadingViews: UIView, UITableViewDataSource, UITableViewDelegate {
    public var tips: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    public func startRoll() {
        beginToRoll()
    }

    public func stopRoll() {
        timer?.cancel()
        timer = nil
    }

    public lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = MTPlayerLoadingTipsViewConfig.textColor
        label.font = MTPlayerLoadingTipsViewConfig.textFont
        label.textAlignment = .center
        return label
    }()

    public lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progress = 1
        view.progressTintColor = MTPlayerLoadingTipsViewConfig.progressColor
        return view
    }()

    public lazy var tableView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.register(LoadingCell.self, forCellReuseIdentifier: LoadingCell.mt_reusedId)
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.rowHeight = MTPlayerLoadingTipsViewConfig.tipsCellRowHeight
        view.backgroundColor = .clear
        return view
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopRoll()
        MTLog(">>>>>>------deinit", self.classForCoder.description())
    }

    private var timer: DispatchSourceTimer?

    private func beginToRoll() {
        stopRoll()

        guard tips.count > 0 else { return }

        tableView.scrollToRow(at: .init(row: 0, section: 0),
                              at: .top,
                              animated: false)

        var index = 0
        let totalCount = tips.count
        var count = MTPlayerLoadingTipsViewConfig.timeDuration

        timer = DispatchSource.makeTimerSource(flags: .init(rawValue: 0), queue: .global())
        timer?.schedule(deadline: .now(), repeating: .milliseconds(1000))
        timer?.setEventHandler(handler: {
            count -= 1
            index += 1
            let toIndex = (index / MTPlayerLoadingTipsViewConfig.scrollInterval) % totalCount
            DispatchQueue.main.async {
                // scroll to next
                let totalCount = self.tableView.numberOfRows(inSection: 0)
                if toIndex < totalCount {
                    self.tableView.scrollToRow(at: .init(row: toIndex, section: 0), at: .top, animated: true)
                }
                self.resultLabel.text = MTPlayerLoadingTipsViewConfig.timeCountingTips + "\(count)s"
                let ratio = Double(count) / Double(MTPlayerLoadingTipsViewConfig.timeDuration == 0 ? 1 : MTPlayerLoadingTipsViewConfig.timeDuration)
                self.progressView.progress = Float(ratio)
                if count <= 0 {
                    self.stopRoll()
                    self.resultLabel.text = MTPlayerLoadingTipsViewConfig.timeCountingFinishTips
                    self.progressView.isHidden = true
                }
            }
        })
        timer?.activate()
    }

    private func configureUI() {
        addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(MTPlayerLoadingTipsViewConfig.tipsCellRowHeight)
        }
        addSubview(resultLabel)
        resultLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview()
        }
        addSubview(progressView)
        progressView.snp.makeConstraints {
            $0.centerY.equalTo(resultLabel).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.6)
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notice = tips[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LoadingCell.mt_reusedId, for: indexPath) as! LoadingCell
        cell.title = notice
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tips.count
    }
}

// MARK: - LoadingCell

private class LoadingCell: UITableViewCell {
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = MTPlayerLoadingTipsViewConfig.textFont
        label.textColor = MTPlayerLoadingTipsViewConfig.textColor
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalTo(8)
            $0.right.greaterThanOrEqualToSuperview().offset(-8).priority(.low)
        }
    }
}
