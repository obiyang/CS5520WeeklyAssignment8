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
        
        // Clear background color
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func setupInitialConstraints() {
        // Create but do not activate constraints
        bubbleLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        
        timeLabelLeadingConstraint = timeLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor)
        timeLabelTrailingConstraint = timeLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor)
        
        // Set fixed constraints
        NSLayoutConstraint.activate([
            // Vertical constraints for bubble view
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            // Constraints for message label
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            // Constraints for time label
            timeLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            timeLabel.heightAnchor.constraint(equalToConstant: 16),
            
            // Max width constraint for bubble view
            bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.75)
        ])
    }
    
    // MARK: - Configuration
    func configure(with message: MessageStruct, isCurrentUser: Bool) {
        messageLabel.text = message.messageBody
        
        // Format timestamp
        let date = Date(timeIntervalSince1970: message.timestamp / 1000)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // Use US date format
        
        // Check if the message is from today
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "'Today' h:mm a"
        }
        // Check if the message is from yesterday
        else if Calendar.current.isDateInYesterday(date) {
            formatter.dateFormat = "Yesterday h:mm a"
        }
        // Check if the message is from this year
        else if Calendar.current.component(.year, from: date) == Calendar.current.component(.year, from: Date()) {
            formatter.dateFormat = "MMM d, h:mm a"
        }
        // Message from other years
        else {
            formatter.dateFormat = "MMM d, yyyy h:mm a"
        }
        
        timeLabel.text = formatter.string(from: date)
        
        // Deactivate all previous constraints
        bubbleLeadingConstraint?.isActive = false
        bubbleTrailingConstraint?.isActive = false
        timeLabelLeadingConstraint?.isActive = false
        timeLabelTrailingConstraint?.isActive = false
        
        if isCurrentUser {
            // Message from current user (align right)
            bubbleView.backgroundColor = UIColor.systemBlue
            messageLabel.textColor = .white
            messageLabel.textAlignment = .left
            bubbleTrailingConstraint?.isActive = true
            timeLabelTrailingConstraint?.isActive = true
            timeLabel.textAlignment = .right
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // Message from other users (align left)
            bubbleView.backgroundColor = UIColor.systemGray5
            messageLabel.textColor = .black
            messageLabel.textAlignment = .left
            bubbleLeadingConstraint?.isActive = true
            timeLabelLeadingConstraint?.isActive = true
            timeLabel.textAlignment = .left
            bubbleView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner]
        }
        
        // Force immediate layout update
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset view state
        bubbleView.backgroundColor = nil
        messageLabel.text = nil
        messageLabel.textAlignment = .left
        timeLabel.text = nil
        
        // Deactivate all constraints
        bubbleLeadingConstraint?.isActive = false
        bubbleTrailingConstraint?.isActive = false
        timeLabelLeadingConstraint?.isActive = false
        timeLabelTrailingConstraint?.isActive = false
    }
}
