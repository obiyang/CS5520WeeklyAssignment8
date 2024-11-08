import UIKit
import FirebaseAuth
import SVProgressHUD

class LogInVC: UIViewController {

    private var logInView: LogInView!
    
    override func loadView() {
        logInView = LogInView()
        view = logInView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Log In"
        
        logInView.loginButton.addTarget(self, action: #selector(tappedOnLogINButton), for: .touchUpInside)
    }
    
    @objc func tappedOnLogINButton() {
        SVProgressHUD.show()
        guard let email = logInView.emailTextField.text, !email.isEmpty,
              let password = logInView.passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Failed", message: "Enter Both The Fields")
            SVProgressHUD.dismiss()
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.showAlert(title: "Login Failed", message: error.localizedDescription)
            } else {
                let chatVC = ChatPageVC()
                self?.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
