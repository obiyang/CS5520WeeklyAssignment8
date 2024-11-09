import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class RegisterVC: UIViewController {
    
    private let registerView: RegisterView = {
        let view = RegisterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTargets()
    }
    
    private func setupView() {
        view.addSubview(registerView)
        
        NSLayoutConstraint.activate([
            registerView.topAnchor.constraint(equalTo: view.topAnchor),
            registerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            registerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            registerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTargets() {
        registerView.createAccountButton.addTarget(
            self,
            action: #selector(tappedOnCreateAccount),
            for: .touchUpInside
        )
    }
    
    @objc private func tappedOnCreateAccount() {
        SVProgressHUD.show()
        
        guard let name = registerView.nameTextField.text, !name.isEmpty,
              let email = registerView.emailTextField.text, !email.isEmpty,
              let pass = registerView.passwordTextField.text, !pass.isEmpty,
              let confirmPass = registerView.confirmPasswordTextField.text, !confirmPass.isEmpty else {
            showAlert(title: "Input Error", message: "Please fill in all fields")
            SVProgressHUD.dismiss()
            return
        }
        
        // Verify password match
        guard pass == confirmPass else {
            showAlert(title: "Wrong Password", message: "The two passwords you entered do not match")
            SVProgressHUD.dismiss()
            return
        }
        
        // Verify password length
        guard pass.count >= 6 else {
            showAlert(title: "Password Error", message: "The password must be at least 6 characters long")
            SVProgressHUD.dismiss()
            return
        }
        
        createNewUser(name: name, email: email, pass: pass)
    }
    
    private func createNewUser(name: String, email: String, pass: String) {
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] (result, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.showAlert(title: "Failed to create user", message: error.localizedDescription)
            } else if let uid = result?.user.uid {
                // Save user info to database
                let userRef = Database.database().reference().child("users").child(uid)
                let userData = [
                    "name": name,
                    "email": email,
                    "uid": uid
                ]
                userRef.setValue(userData) { (error, _) in
                    if let error = error {
                        print("Failed to save user data: \(error.localizedDescription)")
                    } else {
                        // Navigate to user list page
                        let userListVC = UserListVC()
                        self?.navigationController?.pushViewController(userListVC, animated: true)
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
