//  AppDelegate.swift

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 애플리케이션이 시작될 때의 사용자 정의 지점.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // 새로운 씬 세션을 만들 때 호출됨.
        // 새로운 씬을 만들기 위한 설정(configuration)을 선택하는 메서드입니다.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // 사용자가 씬 세션을 폐기할 때 호출됨.
        // 애플리케이션이 실행되지 않은 동안에 폐기된 세션이 있다면,
        // 이 메서드는 application:didFinishLaunchingWithOptions: 이후 짧은 시간 후에 호출됩니다.
        // 폐기된 씬에 특정한 리소스를 해제하기 위해 이 메서드를 사용합니다.
    }
}

