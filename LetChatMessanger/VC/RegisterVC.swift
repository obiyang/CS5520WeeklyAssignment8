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
            showAlert(title: "输入错误", message: "请填写所有字段")
            SVProgressHUD.dismiss()
            return
        }
        
        // 验证密码匹配
        guard pass == confirmPass else {
            showAlert(title: "密码错误", message: "两次输入的密码不匹配")
            SVProgressHUD.dismiss()
            return
        }
        
        // 验证密码长度
        guard pass.count >= 6 else {
            showAlert(title: "密码错误", message: "密码长度至少需要6个字符")
            SVProgressHUD.dismiss()
            return
        }
        
        createNewUser(name: name, email: email, pass: pass)
    }
    
    private func createNewUser(name: String, email: String, pass: String) {
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] (result, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self?.showAlert(title: "无法创建用户", message: error.localizedDescription)
            } else if let uid = result?.user.uid {
                // 保存用户信息到数据库
                let userRef = Database.database().reference().child("users").child(uid)
                let userData = [
                    "name": name,
                    "email": email,
                    "uid": uid
                ]
                userRef.setValue(userData) { (error, _) in
                    if let error = error {
                        print("保存用户数据失败：\(error.localizedDescription)")
                    } else {
                        // 跳转到用户列表页面
                        let userListVC = UserListVC()
                        self?.navigationController?.pushViewController(userListVC, animated: true)
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
