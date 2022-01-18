//
//  AppDelegate.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if AuthManager.shared.isSignedIn {
            AuthManager.shared.refreshIfNeeded(completion: nil)
            window?.rootViewController = TabBarViewController()
        } else {
            let navigationVC = UINavigationController(rootViewController: WelcomeViewController())
            navigationVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            navigationVC.navigationBar.prefersLargeTitles = true
            
            window?.rootViewController = navigationVC
        }
        
        window?.makeKeyAndVisible()
        window?.backgroundColor = .white
        
        return true
    }

}

