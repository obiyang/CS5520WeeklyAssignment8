import UIKit

class ChatPageView: UIView {

    let chatMessagesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatMessage")
        return tableView
    }()
    
    let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let messageSendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        addSubview(chatMessagesTableView)
        addSubview(messageTextField)
        addSubview(messageSendButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            chatMessagesTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatMessagesTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatMessagesTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatMessagesTableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),
            
            messageTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            messageTextField.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            messageTextField.trailingAnchor.constraint(equalTo: messageSendButton.leadingAnchor, constant: -10),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            messageSendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageSendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            messageSendButton.widthAnchor.constraint(equalToConstant: 60),
            messageSendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}