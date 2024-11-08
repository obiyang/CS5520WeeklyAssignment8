import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 检查是否能将 scene 转换为 UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // 创建新的 UIWindow 并附加到 windowScene
        window = UIWindow(windowScene: windowScene)
        
        // 设置根视图控制器，这里使用导航控制器包裹 HomeVC
        let rootViewController = HomeVC() // 使用你的主视图控制器，例如 HomeVC
        let navigationController = UINavigationController(rootViewController: rootViewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 这里处理场景断开连接时的逻辑
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 这里处理场景变为活跃状态时的逻辑
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 这里处理场景变为非活跃状态时的逻辑
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 这里处理场景进入前台时的逻辑
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 这里处理场景进入后台时的逻辑
    }
}
