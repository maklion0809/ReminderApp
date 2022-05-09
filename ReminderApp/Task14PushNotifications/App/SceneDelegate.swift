//
//  SceneDelegate.swift
//  Task14PushNotifications
//
//  Created by Tymofii (Work) on 09.11.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let controller = ReminderViewController()
        let presenter = ReminderPresenter()
        controller.presenter = presenter
        let navigation = UINavigationController(rootViewController: controller)
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        self.window = window
    }
}

