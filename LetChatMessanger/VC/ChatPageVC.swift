import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ChatPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mesArray: [MessagesStructt] = []
    private var chatPageView: ChatPageView!
    
    override func loadView() {
        chatPageView = ChatPageView()
        view = chatPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationBarSetUp()
        
        chatPageView.chatMessagesTableView.dataSource = self
        chatPageView.chatMessagesTableView.delegate = self
        
        chatPageView.messageSendButton.addTarget(self, action: #selector(tappedOnMessageSendButton), for: .touchUpInside)
        
        retriiveMessageFromDataBase()
    }

    func navigationBarSetUp() {
        navigationItem.title = "Chatting Page"
        navigationItem.hidesBackButton = true
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logOutButton
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let error as NSError {
            print("Error while logging out: \(error)")
        }
    }
    
    @objc func tappedOnMessageSendButton() {
        guard let messageText = chatPageView.messageTextField.text, !messageText.isEmpty else { return }
        chatPageView.messageTextField.isEnabled = false
        chatPageView.messageSendButton.isEnabled = false
        
        let messageDictionary = [
            "SenderId": Auth.auth().currentUser?.email ?? "",
            "MessageBody": messageText
        ]
        
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.childByAutoId().setValue(messageDictionary) { [weak self] (error, _) in
            self?.chatPageView.messageTextField.isEnabled = true
            self?.chatPageView.messageSendButton.isEnabled = true
            if error == nil {
                self?.chatPageView.messageTextField.text = ""
            }
        }
    }
    
    func retriiveMessageFromDataBase() {
        let messageDB = Database.database().reference().child("Messages")
        messageDB.observe(.childAdded) { [weak self] (snapshot) in
            if let snapshotValue = snapshot.value as? [String: String],
               let textMsg = snapshotValue["MessageBody"],
               let sender = snapshotValue["SenderId"] {
                self?.mesArray.append(MessagesStructt(user: sender, messageBody: textMsg))
                self?.chatPageView.chatMessagesTableView.reloadData()
                self?.scrollToBottom()
            }
        }
    }
    
    func scrollToBottom() {
        if mesArray.count > 0 {
            let indexPath = IndexPath(row: mesArray.count - 1, section: 0)
            chatPageView.chatMessagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatMessage", for: indexPath)
        let message = mesArray[indexPath.row]
        cell.textLabel?.text = "\(message.user): \(message.messageBody)"
        return cell
    }
}
