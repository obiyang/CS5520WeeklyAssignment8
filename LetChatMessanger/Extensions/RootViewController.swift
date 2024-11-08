
import UIKit
//For testing purpose if need to jump to a specific screen ignoring unnecessary screens
func changeRootViewController(to rootVC: UIViewController) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else {return }
    window.rootViewController = rootVC
    window.makeKeyAndVisible()
    
}
