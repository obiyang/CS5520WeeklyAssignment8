import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class ChatPageVC: UIViewController {
    
    // MARK: - Properties
    var mesArray: [MessageStruct] = []
    var otherUserEmail: String?
    var otherUserName: String?
    
    private let chatPageView: ChatPageView = {
        let view = ChatPageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchOtherUserName()
        navigationBarSetUp()
        setupTableView()
        retriveMessageFromDataBase()
        setupMessageSending()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Scroll to the bottom after the view layout is completed
        scrollToBottom(animated: false)
    }
    
    // MARK: - Setup Methods
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
        chatPageView.chatMessagesTableView.rowHeight = UITableView.automaticDimension
        chatPageView.chatMessagesTableView.estimatedRowHeight = 60
    }
    
    private func setupMessageSending() {
        chatPageView.messageSendButton.addTarget(
            self,
            action: #selector(tappedOnMessageSendButton),
            for: .touchUpInside
        )
    }
    
    private func fetchOtherUserName() {
        guard let otherEmail = otherUserEmail else { return }
        
        let usersRef = Database.database().reference().child("users")
        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: otherEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            for child in snapshot.children {
                if let userSnapshot = child as? DataSnapshot,
                   let userData = userSnapshot.value as? [String: Any],
                   let name = userData["name"] as? String {
                    self?.otherUserName = name
                    // Update navigation bar title
                    self?.navigationItem.title = name
                    break
                }
            }
        }
    }
    
    // MARK: - Navigation Setup
    func navigationBarSetUp() {
        navigationItem.title = otherUserName ?? otherUserEmail
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logOutButton
    }
    
    // MARK: - Action Methods
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Failed to log out: \(error)")
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
        
        // Find the receiver's UID
        let usersRef = Database.database().reference().child("users")
        usersRef.queryOrdered(byChild: "email").queryEqual(toValue: otherUserEmail).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            for child in snapshot.children {
                if let userSnapshot = child as? DataSnapshot,
                   let userData = userSnapshot.value as? [String: Any],
                   let _ = userData["email"] as? String {
                    let receiverUID = userSnapshot.key
                    
                    // Generate a unique message ID
                    let messageId = Database.database().reference().child("messages").childByAutoId().key ?? ""
                    
                    // Create multi-path updates
                    var multiPathUpdates: [String: Any] = [:]
                    
                    // Store message for sender
                    let senderPath = "private_messages/\(Auth.auth().currentUser?.uid ?? "")/\(self.otherUserEmail?.replacingOccurrences(of: ".", with: "_") ?? "")/\(messageId)"
                    multiPathUpdates[senderPath] = messageDictionary
                    
                    // Store message for receiver
                    let receiverPath = "private_messages/\(receiverUID)/\(currentUserEmail.replacingOccurrences(of: ".", with: "_"))/\(messageId)"
                    multiPathUpdates[receiverPath] = messageDictionary
                    
                    // Perform multi-path update
                    Database.database().reference().updateChildValues(multiPathUpdates) { [weak self] error, _ in
                        if error == nil {
                            self?.chatPageView.messageTextField.text = ""
                            // Scroll to the bottom after sending
                            self?.scrollToBottom()
                        }
                        self?.chatPageView.messageTextField.isEnabled = true
                        self?.chatPageView.messageSendButton.isEnabled = true
                    }
                    break
                }
            }
        }
    }
    
    // MARK: - Database Methods
    func retriveMessageFromDataBase() {
        guard let currentUserUID = Auth.auth().currentUser?.uid,
              let otherEmail = otherUserEmail else { return }
        
        print("Current User UID: \(currentUserUID)")
        print("Other Email: \(otherEmail)")
        
        let messageDB = Database.database().reference().child("private_messages")
            .child(currentUserUID)
            .child(otherEmail.replacingOccurrences(of: ".", with: "_"))
        
        // Retrieve messages ordered by timestamp
        messageDB.queryOrdered(byChild: "timestamp").observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            print("Message Fetched: \(snapshot.value ?? "Empty")")
            
            // Clear existing messages
            self.mesArray.removeAll()
            
            // Iterate over all messages
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
            
            // Sort messages by timestamp
            self.mesArray.sort { $0.timestamp < $1.timestamp }
            
            // Update UI
            self.chatPageView.chatMessagesTableView.reloadData()
            // Use animated: false to avoid animation on initial load
            self.scrollToBottom(animated: false)
        }
    }
    
    private func scrollToBottom(animated: Bool = true) {
        DispatchQueue.main.async {
            if !self.mesArray.isEmpty {
                let indexPath = IndexPath(row: self.mesArray.count - 1, section: 0)
                self.chatPageView.chatMessagesTableView.scrollToRow(
                    at: indexPath,
                    at: .bottom,
                    animated: animated
                )
            }
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
