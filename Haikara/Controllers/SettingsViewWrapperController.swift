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
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	
		self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
    }
}