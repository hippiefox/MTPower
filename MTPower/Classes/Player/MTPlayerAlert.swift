//
//  MTPlayerAlert.swift
//  MTPower
//
//  Created by PanGu on 2022/10/30.
//

import Foundation

// MARK: MTPlayerAlertOption

public protocol MTPlayerAlertOption: Equatable {
    var title: String { get }
}

// MARK: MTPlayerAlert

open class MTPlayerAlert<Option: MTPlayerAlertOption>: MTProtoAlert, UITableViewDataSource, UITableViewDelegate {
    public init(defaultOption: Option,
                options: [Option],
                position: MTProtoAlert.Position,
                tapToDismiss: Bool = true)
    {
        super.init(position: position, tapToDismiss: tapToDismiss)
        currentOption = defaultOption
        self.options = options
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public var currentOption: Option!
    public var options: [Option]!
    public var optBlock: ((Option) -> Void)?

    public lazy var tableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.register(MTPlayerAlertCell.self, forCellReuseIdentifier: MTPlayerAlertCell.mt_reusedId)
        view.showsVerticalScrollIndicator = false
        view.rowHeight = MT_Baseline(50)
        view.separatorStyle = .none
        view.backgroundColor = .clear
        return view
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    open override func adjustContainerFrame(before animatePosition: MTProtoAlert.Position) {
        switch animatePosition{
        case .bottom:
            containerView.frame.size.height = CGFloat(options.count) * MT_Baseline(50) + MT_Baseline(20 * 2)
        case .right:
            containerView.frame.size.width = MT_Baseline(280)
        default:    break
        }
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opt = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MTPlayerAlertCell.mt_reusedId, for: indexPath) as! MTPlayerAlertCell
        cell.title = opt.title
        cell.isChoosed = currentOption == opt
        return cell
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let opt = options[indexPath.row]
        currentOption = opt
        tableView.reloadData()
        dismiss(animated: true) {
            self.optBlock?(opt)
        }
    }

    private func configureUI() {
        containerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(MT_Baseline(20))
            $0.bottom.equalToSuperview().offset(MT_Baseline(-10))
            $0.left.right.equalToSuperview()
        }
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(MT_Baseline(40))
            $0.top.equalTo(MT_Baseline(10))
            $0.right.equalTo(tableView)
        }
        closeButton.iconNormal = MTPlayerConfig.close
    }
}

// MARK: MTPlayerAlertCell

public class MTPlayerAlertCell: UITableViewCell {
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public var isChoosed: Bool = false {
        didSet {
            titleLabel.textColor = isChoosed ? MTPlayerConfig.progressColor : .white
            titleLabel.backgroundColor = isChoosed ? UIColor(red: 22 / 255.0, green: 22 / 255.0, blue: 22 / 255.0, alpha: 1) : .clear
        }
    }

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        titleLabel.layer.cornerRadius = 8
        titleLabel.layer.masksToBounds = true
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(MT_Baseline(25))
            $0.right.equalToSuperview().offset(MT_Baseline(-25))
            $0.height.equalTo(MT_Baseline(50))
            $0.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
