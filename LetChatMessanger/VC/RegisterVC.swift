import UIKit
import FirebaseAuth
import SVProgressHUD

class RegisterVC: UIViewController {

    private var registerView: RegisterView!
    
    override func loadView() {
        registerView = RegisterView()
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create An Account"
        
        registerView.createAccountButton.addTarget(self, action: #selector(tappedOnCreateAccount), for: .touchUpInside)
    }

    @objc func tappedOnCreateAccount() {
        SVProgressHUD.show()
        guard let email = registerView.emailTextField.text, !email.isEmpty,
              let pass = registerView.passwordTextField.text, !pass.isEmpty else {
            showAlert(title: "Empty Fields", message: "Please Fill In Both Fields")
            SVProgressHUD.dismiss()
            return
        }
        createNewUser(email: email, pass: pass)
    }
    
    func createNewUser(email: String, pass: String) {
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] (result, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.showAlert(title: "Cannot Create User", message: error.localizedDescription)
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
