import UIKit
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class RegisterVC: UIViewController {
    
    // MARK: - Properties
    private let registerView: RegisterView = {
        let view = RegisterView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTargets()
        setupKeyboardDismissal()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .white
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
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Validation Methods
    private func validateInputs() -> (isValid: Bool, message: String?) {
        // Check for empty fields
        guard let name = registerView.nameTextField.text, !name.trimmingCharacters(in: .whitespaces).isEmpty,
              let email = registerView.emailTextField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty,
              let pass = registerView.passwordTextField.text, !pass.isEmpty,
              let confirmPass = registerView.confirmPasswordTextField.text, !confirmPass.isEmpty else {
            return (false, "Please fill in all fields")
        }
        
        // Validate name length
        if name.trimmingCharacters(in: .whitespaces).count < 2 {
            return (false, "Name must be at least 2 characters long")
        }
        
        // Validate email format
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !emailPred.evaluate(with: email) {
            return (false, "Please enter a valid email address")
        }
        
        // Validate password length and complexity
        if pass.count < 6 {
            return (false, "Password must be at least 6 characters long")
        }
        
        // Validate password complexity
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        if !passwordPred.evaluate(with: pass) {
            return (false, "Password must contain at least one letter and one number")
        }
        
        // Validate password match
        if pass != confirmPass {
            return (false, "Passwords do not match")
        }
        
        return (true, nil)
    }
    
    // MARK: - Action Methods
    @objc private func tappedOnCreateAccount() {
        SVProgressHUD.show()
        
        let validation = validateInputs()
        if !validation.isValid {
            SVProgressHUD.dismiss()
            showAlert(title: "Input Error", message: validation.message ?? "Invalid input")
            return
        }
        
        guard let name = registerView.nameTextField.text?.trimmingCharacters(in: .whitespaces),
              let email = registerView.emailTextField.text?.trimmingCharacters(in: .whitespaces),
              let pass = registerView.passwordTextField.text else {
            return
        }
        
        // Confirm account creation
        let alert = UIAlertController(
            title: "Create Account",
            message: "Are you sure you want to create an account with email: \(email)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            SVProgressHUD.dismiss()
        })
        
        alert.addAction(UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            self?.createNewUser(name: name, email: email, pass: pass)
        })
        
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - User Creation
    private func createNewUser(name: String, email: String, pass: String) {
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] (result, error) in
            SVProgressHUD.dismiss()
            
            if let error = error {
                self?.showAlert(
                    title: "Registration Failed",
                    message: self?.getFirebaseErrorMessage(error) ?? error.localizedDescription
                )
            } else if let uid = result?.user.uid {
                let userRef = Database.database().reference().child("users").child(uid)
                let userData = [
                    "name": name,
                    "email": email,
                    "uid": uid,
                    "createdAt": ServerValue.timestamp()
                ]
                
                userRef.setValue(userData) { [weak self] (error, _) in
                    if let error = error {
                        self?.showAlert(
                            title: "Error",
                            message: "Account created but failed to save user data: \(error.localizedDescription)"
                        )
                    } else {
                        self?.showSuccessAlert(email: email)
                    }
                }
            }
        }
    }
    
    // MARK: - Alert Methods
    private func showSuccessAlert(email: String) {
        let alert = UIAlertController(
            title: "Success",
            message: "Account created successfully with email: \(email)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            let userListVC = UserListVC()
            self?.navigationController?.pushViewController(userListVC, animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func getFirebaseErrorMessage(_ error: Error) -> String {
        let errorCode = (error as NSError).code
        switch errorCode {
        case 17007:
            return "This email is already registered. Please use a different email or try logging in."
        case 17008:
            return "Invalid email format."
        case 17026:
            return "Password is too weak. Please use a stronger password."
        default:
            return error.localizedDescription
        }
    }
}

// MARK: - UITextFieldDelegate
extension RegisterVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case registerView.nameTextField:
            registerView.emailTextField.becomeFirstResponder()
        case registerView.emailTextField:
            registerView.passwordTextField.becomeFirstResponder()
        case registerView.passwordTextField:
            registerView.confirmPasswordTextField.becomeFirstResponder()
        case registerView.confirmPasswordTextField:
            textField.resignFirstResponder()
            tappedOnCreateAccount()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
