//
//  SettingsViewWrapperController.swift
//  highkara
//
//  Created by Marko Wallin on 12.8.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

class SettingsViewWrapperController: UIViewController {

    var navigationItemTitle: String = NSLocalizedString("SETTINGS_TITLE", comment: "Title for settings view")
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	
		setObservers()
		setTheme()
    }
	
	func setObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewWrapperController.setTheme(_:)), name: .themeChangedNotification, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tabBarController?.tabBar.barStyle = Theme.barStyle
	}

	func setTheme(_ notification: Notification) {
        #if DEBUG
            print("SettingsViewWrapperController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	// stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
