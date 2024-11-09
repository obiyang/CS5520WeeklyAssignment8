import UIKit
import FirebaseAuth
import FirebaseDatabase

class UserListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var userListView: UserListView!
    private var users: [User] = []
    
    struct User {
        let name: String
        let email: String
        let uid: String
    }
    
    override func loadView() {
        userListView = UserListView()
        view = userListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        fetchUsers()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "User List"
        navigationItem.hidesBackButton = true
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.rightBarButtonItem = logOutButton
    }
    
    private func setupTableView() {
        userListView.userTableView.delegate = self
        userListView.userTableView.dataSource = self
    }
    
    private func fetchUsers() {
        print("Start fetching users")
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.value) { [weak self] snapshot in
            print("Get data: \(snapshot.value ?? "Empty")")
            self?.users.removeAll()
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let userData = snapshot.value as? [String: Any],
                   let email = userData["email"] as? String,
                   let name = userData["name"] as? String {
                    if email != currentUserEmail {
                        print("Parsed user: \(email)")
                        let user = User(name: name, email: email, uid: snapshot.key)
                        self?.users.append(user)
                    }
                }
            }
            
            print("Current user list count: \(self?.users.count ?? 0)")
            self?.userListView.userTableView.reloadData()
        }
    }
    
    @objc func logoutButtonTapped() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Logout error: \(error)")
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.name)"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = users[indexPath.row]
        let chatVC = ChatPageVC()
        chatVC.otherUserEmail = selectedUser.email
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
