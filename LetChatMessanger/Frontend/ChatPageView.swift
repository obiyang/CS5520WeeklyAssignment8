import UIKit

class ChatPageView: UIView {

    var messageInputBottomConstraint: NSLayoutConstraint?

    let chatMessagesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chatMessage")
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    let messageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .send
        textField.enablesReturnKeyAutomatically = true
        return textField
    }()
    
    let messageSendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupTextFieldHandling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupTextFieldHandling()
    }

    private func setupViews() {
        backgroundColor = .white
        addSubview(chatMessagesTableView)
        addSubview(messageTextField)
        addSubview(messageSendButton)
    }

    private func setupConstraints() {
        messageInputBottomConstraint = messageTextField.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor,
            constant: -10
        )
        
        NSLayoutConstraint.activate([
            chatMessagesTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatMessagesTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatMessagesTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatMessagesTableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),
            
            messageTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            messageInputBottomConstraint!,
            messageTextField.trailingAnchor.constraint(equalTo: messageSendButton.leadingAnchor, constant: -10),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            messageSendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            messageSendButton.bottomAnchor.constraint(equalTo: messageTextField.bottomAnchor),
            messageSendButton.widthAnchor.constraint(equalToConstant: 60),
            messageSendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupTextFieldHandling() {
        messageTextField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        messageSendButton.isEnabled = !(textField.text?.isEmpty ?? true)
    }

    func clearMessageField() {
        messageTextField.text = ""
        messageSendButton.isEnabled = false
    }
}
