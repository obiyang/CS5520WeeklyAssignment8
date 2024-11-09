import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class ChatPageVC: UIViewController {
    
    var mesArray: [MessageStruct] = []
    var otherUserEmail: String?
    
    private let chatPageView: ChatPageView = {
        let view = ChatPageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        navigationBarSetUp()
        retriveMessageFromDataBase()
        setupTableView()
        setupMessageSending()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(chatPageView)
        
        NSLayoutConstraint.activate([
            chatPageView.topAnchor.constraint(equalTo: view.topAnchor),
            chatPageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatPageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatPageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        chatPageView.chatMessagesTableView.delegate = self
        chatPageView.chatMessagesTableView.dataSource = self
        chatPageView.chatMessagesTableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
    }
    
    private func setupMessageSending() {
        chatPageView.messageSendButton.addTarget(self, action: #selector(tappedOnMessageSendButton), for: .touchUpInside)
    }
    
    func navigationBarSetUp() {
        navigationItem.title = otherUserEmail
        // 不再隐藏返回按钮
        let logOutButton = UIBarButtonItem(title: "退出", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logOutButton
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("退出登录错误: \(error)")
        }
    }
    
    @objc func tappedOnMessageSendButton() {
        guard let messageText = chatPageView.messageTextField.text, !messageText.isEmpty,
              let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        chatPageView.messageTextField.isEnabled = false
        chatPageView.messageSendButton.isEnabled = false
        
        let timestamp = Date().timeIntervalSince1970 * 1000
        
        let messageDictionary: [String: Any] = [
            "SenderId": currentUserEmail,
            "MessageBody": messageText,
            "timestamp": timestamp
        ]
        
        // 查找接收者的 UID
        let usersRef = Database.database().reference().child("users")
        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: otherUserEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            for child in snapshot.children {
                if let userSnapshot = child as? DataSnapshot,
                   let userData = userSnapshot.value as? [String: Any],
                   let _ = userData["email"] as? String {
                    let receiverUID = userSnapshot.key
                    
                    // 生成一个唯一的消息ID
                    let messageId = Database.database().reference().child("messages").childByAutoId().key ?? ""
                    
                    // 创建多路径更新
                    var multiPathUpdates: [String: Any] = [:]
                    
                    // 为发送者存储消息
                    let senderPath = "private_messages/\(Auth.auth().currentUser?.uid ?? "")/\(self.otherUserEmail?.replacingOccurrences(of: ".", with: "_") ?? "")/\(messageId)"
                    multiPathUpdates[senderPath] = messageDictionary
                    
                    // 为接收者存储消息
                    let receiverPath = "private_messages/\(receiverUID)/\(currentUserEmail.replacingOccurrences(of: ".", with: "_"))/\(messageId)"
                    multiPathUpdates[receiverPath] = messageDictionary
                    
                    // 执行多路径更新
                    Database.database().reference().updateChildValues(multiPathUpdates) { [weak self] error, _ in
                        if error == nil {
                            self?.chatPageView.messageTextField.text = ""
                        }
                        self?.chatPageView.messageTextField.isEnabled = true
                        self?.chatPageView.messageSendButton.isEnabled = true
                    }
                    break
                }
            }
        }
    }
    
    func retriveMessageFromDataBase() {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let otherEmail = otherUserEmail else { return }
        
        print("当前用户UID: \(currentUserUID)")
        print("对方邮箱: \(otherEmail)")
        
        let messageDB = Database.database().reference().child("private_messages")
            .child(currentUserUID)
            .child(otherEmail.replacingOccurrences(of: ".", with: "_"))
        
        // 按时间戳排序获取消息
        messageDB.queryOrdered(byChild: "timestamp").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            print("获取到的消息数据: \(snapshot.value ?? "空")")
            
            // 清空现有消息
            self.mesArray.removeAll()
            
            // 遍历所有消息
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let messageData = snapshot.value as? [String: Any],
                   let textMsg = messageData["MessageBody"] as? String,
                   let sender = messageData["SenderId"] as? String,
                   let timestamp = messageData["timestamp"] as? Double {
                    
                    let message = MessageStruct(
                        user: sender,
                        messageBody: textMsg,
                        timestamp: timestamp,
                        messageId: snapshot.key
                    )
                    self.mesArray.append(message)
                }
            }
            
            // 按时间戳排序
            self.mesArray.sort { $0.timestamp < $1.timestamp }
            
            // 更新UI
            self.chatPageView.chatMessagesTableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        if !mesArray.isEmpty {
            let indexPath = IndexPath(row: mesArray.count - 1, section: 0)
            chatPageView.chatMessagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ChatPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.identifier,
            for: indexPath
        ) as? MessageCell else {
            return UITableViewCell()
        }
        
        let message = mesArray[indexPath.row]
        let isCurrentUser = message.user == Auth.auth().currentUser?.email
        cell.configure(with: message, isCurrentUser: isCurrentUser)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
