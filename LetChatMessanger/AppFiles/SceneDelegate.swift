import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Check if scene can be cast to UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create a new UIWindow and attach it to the windowScene
        window = UIWindow(windowScene: windowScene)
        
        // Set the root view controller, using a navigation controller with HomeVC as the root
        let rootViewController = HomeVC() // Use your main view controller, such as HomeVC
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Handle logic when the scene disconnects
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Handle logic when the scene becomes active
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Handle logic when the scene will resign active state
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Handle logic when the scene enters the foreground
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Handle logic when the scene enters the background
    }
}
