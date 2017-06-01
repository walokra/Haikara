//
//  GlobalSplitViewController.swift
//  highkara
//
//  Created by Marko Wallin on 01/06/2017.
//  Copyright © 2017 Rule of tech. All rights reserved.
//

import Foundation

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()

		self.delegate = self
	
		splitViewController?.delegate = self
		splitViewController?.presentsWithGesture = true
		navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		navigationItem.leftItemsSupplementBackButton = true
  }

  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool{
    return true
  }

}
