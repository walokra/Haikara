//
//  InfoController.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class InfoController: UITableViewController {

	let viewName = "InfoView"

	let settings = Settings.sharedInstance

	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var licenseLabel: UILabel!
	@IBOutlet weak var aboutLabel: UILabel!

	@IBOutlet weak var openHighFiButton: UIButton!
	@IBAction func openHighFi(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://high.fi/")!)
	}

	@IBOutlet weak var openAppStoreButton: UIButton!
	@IBAction func openAppStore(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://itunes.apple.com/us/app/highkara-uutislukija/id1035170336")!)
	}

	@IBOutlet weak var openTwitterButton: UIButton!
	@IBAction func openTwitter(sender: AnyObject) {
	let url = NSURL(string: "twitter://user?screen_name=walokra")
		if UIApplication.sharedApplication().canOpenURL(url!) {
			UIApplication.sharedApplication().openURL(url!)
		} else {
	        UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/walokra")!)
		}
	}

	@IBOutlet weak var bugsButton: UIButton!
	@IBAction func openBugs(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/walokra/haikara/issues")!)
	}

	@IBOutlet weak var openEmailButton: UIButton!
	@IBAction func openEmail(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "mailto:marko.wallin@iki.fi")!)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		setObservers()
		setContentSize()
		setTheme()
		configureTableView()
		
		sendScreenView(viewName)
		
        infoLabel.text = settings.appID + ", Marko Wallin"
	}
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InfoController.setTheme(_:)), name: "themeChangedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InfoController.setContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
		aboutLabel.textColor = Theme.textColor
		licenseLabel.textColor = Theme.textColor
		openAppStoreButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		openHighFiButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		bugsButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		openTwitterButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		openEmailButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		
		infoLabel.textColor = Theme.textColor
	}
	
	func setTheme(notification: NSNotification) {
		#if DEBUG
            print("Received themeChangedNotification")
        #endif
		setTheme()
    }
	
	func setContentSize() {
		infoLabel.font = settings.fontSizeSmall
		aboutLabel.font = settings.fontSizeLarge
		licenseLabel.font = settings.fontSizeSmall
		openAppStoreButton.titleLabel?.font = settings.fontSizeLarge
		openHighFiButton.titleLabel?.font = settings.fontSizeLarge
		bugsButton.titleLabel?.font = settings.fontSizeLarge
		openTwitterButton.titleLabel?.font = settings.fontSizeLarge
		openEmailButton.titleLabel?.font = settings.fontSizeLarge
		
		tableView.reloadData()
	}
	
	func setContentSize(notification: NSNotification) {
		#if DEBUG
            print("Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
    }

	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75.0
	}
	
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
   		// Change the color of all cells
   		cell.backgroundColor = Theme.backgroundColor
		cell.textLabel!.textColor = Theme.cellTitleColor
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		cell.selectionStyle = .None
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))

		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor
		
		var sectionLabel: UILabel
		sectionLabel = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width/2, 20))
		sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
		sectionLabel.textColor = Theme.sectionTitleColor
		sectionLabel.font = settings.fontSizeLarge
		
		headerView.addSubview(sectionLabel)
		
    	return headerView
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
