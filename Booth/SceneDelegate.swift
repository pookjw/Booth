//
//  SceneDelegate.swift
//  Booth
//
//  Created by Jinwoo Kim on 9/24/23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let windowScene: UIWindowScene = scene as! UIWindowScene
        let window: UIWindow = .init(windowScene: windowScene)
        let rootViewController: EffectsViewController = .init()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }
}
