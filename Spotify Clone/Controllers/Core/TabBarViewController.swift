//
//  TabBarViewController.swift
//  Spotify
//
//  Created by Le Hoang Anh on 17/01/2022.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = HomeViewController()
        let searchVC = SearchViewController()
        let libVC = LibraryViewController()
        
        homeVC.title = "Browse"
        searchVC.title = "Search"
        libVC.title = "Library"
        
        homeVC.navigationItem.largeTitleDisplayMode = .always
        searchVC.navigationItem.largeTitleDisplayMode = .always
        libVC.navigationItem.largeTitleDisplayMode = .always
        
        let homeNavigationVC = UINavigationController(rootViewController: homeVC)
        let searchNavigationVC = UINavigationController(rootViewController: searchVC)
        let libNavigationVC = UINavigationController(rootViewController: libVC)
        
        homeNavigationVC.navigationBar.tintColor = .label
        searchNavigationVC.navigationBar.tintColor = .label
        libNavigationVC.navigationBar.tintColor = .label
        
        homeNavigationVC.tabBarItem = UITabBarItem(
            title: "Home", image: UIImage(systemName: "house"), tag: 1
        )
        searchNavigationVC.tabBarItem = UITabBarItem(
            title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2
        )
        libNavigationVC.tabBarItem = UITabBarItem(
            title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3
        )
        
        homeNavigationVC.navigationBar.prefersLargeTitles = true
        searchNavigationVC.navigationBar.prefersLargeTitles = true
        libNavigationVC.navigationBar.prefersLargeTitles = true
        
        setViewControllers(
            [homeNavigationVC, searchNavigationVC, libNavigationVC],
            animated: true
        )
        
        // testing, needs to remove
        selectedIndex = 2
    }

}
