import UIKit

class MessageCell: UITableViewCell {
    static let identifier = "MessageCell"
    
    // MARK: - UI Components
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Constraints
    private var bubbleLeadingConstraint: NSLayoutConstraint?
    private var bubbleTrailingConstraint: NSLayoutConstraint?
    private var timeLabelLeadingConstraint: NSLayoutConstraint?
    private var timeLabelTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupInitialConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        // 清除背景色
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupInitialConstraints() {
        // 创建但不激活约束
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        timeLabelLeadingConstraint = timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        timeLabelTrailingConstraint = timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
        
        // 设置固定约束
        NSLayoutConstraint.activate([
            // 气泡视图的垂直约束
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            // 消息标签的约束
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            // 时间标签的约束
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            timeLabel.heightAnchor.constraint(equalToConstant: 16),
            
            // 气泡最大宽度约束
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.75)
        ])
    }
    
    // MARK: - Configuration
    func configure(with message: MessageStruct, isCurrentUser: Bool) {
        messageLabel.text = message.messageBody
        
        // 格式化时间戳
        let date = Date(timeIntervalSince1970: message.timestamp / 1000)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // 使用中文日期格式
        
        // 判断是否是今天的消息
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        }
        // 判断是否是昨天的消息
        else if Calendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "Yesterday h:mm a"
        }
        // 判断是否是今年的消息
        else if Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: Date()) {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        // 其他年份的消息
        else {
            formatter.dateFormat = "MMM d, yyyy h:mm a"
        }
        
        timeLabel.text = formatter.string(from: date)
        
        // 停用所有之前的约束
        bubbleLeadingConstraint?.isActive = false
        bubbleTrailingConstraint?.isActive = false
        timeLabelLeadingConstraint?.isActive = false
        timeLabelTrailingConstraint?.isActive = false
        
        if isCurrentUser {
            // 当前用户的消息（靠右）
            bubbleView.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white
            messageLabel.textAlignment = .left
            bubbleTrailingConstraint?.isActive = true
            timeLabelTrailingConstraint?.isActive = true
            timeLabel.textAlignment = .right
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // 其他用户的消息（靠左）
            bubbleView.backgroundColor = UIColor.systemGray5
            messageLabel.textColor = .black
            messageLabel.textAlignment = .left
            bubbleLeadingConstraint?.isActive = true
            timeLabelLeadingConstraint?.isActive = true
            timeLabel.textAlignment = .left
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
        
        // 强制立即更新布局
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置视图状态
        bubbleView.backgroundColor = nil
        messageLabel.text = nil
        messageLabel.textAlignment = .left
        timeLabel.text = nil
        
        // 停用所有约束
        bubbleLeadingConstraint?.isActive = false
        bubbleTrailingConstraint?.isActive = false
        timeLabelLeadingConstraint?.isActive = false
        timeLabelTrailingConstraint?.isActive = false
    }
}
