import UIKit

class HomeVC: UIViewController {
    
    private var homeView: HomeView!
    
    override func loadView() {
        homeView = HomeView()
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Welcome"
        
        // Add target actions for buttons
        homeView.loginButton.addTarget(self, action: #selector(tappedOnButton(_:)), for: .touchUpInside)
        homeView.registerButton.addTarget(self, action: #selector(tappedOnButton(_:)), for: .touchUpInside)
    }

    @objc func tappedOnButton(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            let vc = LogInVC()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let regVC = RegisterVC()
            navigationController?.pushViewController(regVC, animated: true)
        default:
            print("Tapped on an unknown button")
        }
    }
}
