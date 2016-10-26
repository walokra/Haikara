//
//  DisplaySettingsViewController.swift
//  highkara
//
//  Created by Marko Wallin on 26/10/2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

class DisplaySettingsViewController: UITableViewController {

	let viewName = "DisplaySettingsView"

	let settings = Settings.sharedInstance
	var defaults: NSUserDefaults?

	// Mark: Outlets
	@IBOutlet weak var previewImage: UIImageView!
	@IBOutlet weak var previewTitle: UILabel!
	@IBOutlet weak var previewAuthor: UILabel!
	@IBOutlet weak var previewDescription: UILabel!
	@IBOutlet weak var previewCell: UITableViewCell!
	@IBOutlet weak var previewContent: UIView!
	@IBOutlet weak var previewImageWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var previewTitleLeadingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var showDescLabel: UILabel!
	@IBOutlet weak var showDescDesc: UILabel!
	@IBOutlet weak var showDescSwitch: UISwitch!
	@IBOutlet weak var showNewsPictureLabel: UILabel!
	@IBOutlet weak var showNewsPictureDesc: UILabel!
	@IBOutlet weak var showNewsPictureSwitch: UISwitch!
	@IBOutlet weak var useSystemSizeLabel: UILabel!
	@IBOutlet weak var useSystemSizeSwitch: UISwitch!
	
	@IBAction func showDescAction(sender: UISwitch) {
		settings.showDesc = sender.on
        defaults!.setObject(settings.showDesc, forKey: "showDesc")
		defaults!.synchronize()
        #if DEBUG
            print ("showDesc \(settings.showDesc), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("showDesc", category: "ui_Event", action: "showDesc", label: "settings", value: (sender.on) ? 1 : 0)
		
		renderPreview()
	}

	@IBAction func showNewsPictureAction(sender: UISwitch) {
		settings.showNewsPicture = sender.on
        defaults!.setObject(settings.showNewsPicture, forKey: "showNewsPicture")
		defaults!.synchronize()
        #if DEBUG
            print ("showNewsPicture \(settings.showNewsPicture), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("showNewsPicture", category: "ui_Event", action: "showNewsPicture", label: "settings", value: (sender.on) ? 1 : 0)
		
		renderPreview()
	}
	
	@IBAction func useSystemSizeAction(sender: UISwitch) {
		settings.useSystemSize = sender.on
        defaults!.setObject(settings.useSystemSize, forKey: "useSystemSize")
		defaults!.synchronize()
        #if DEBUG
            print ("useSystemSize \(settings.useSystemSize), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("useSystemSize", category: "ui_Event", action: "useSystemSize", label: "settings", value: (sender.on) ? 1 : 0)
		
		renderPreview()
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		setObservers()
		configureTableView()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
		renderPreview()

        showDescSwitch.on = settings.showDesc
		showNewsPictureSwitch.on = settings.showNewsPicture
    }
	
	func configureTableView() {
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 110.0
	}
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DisplaySettingsViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DisplaySettingsViewController.setContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DisplaySettingsViewController.reset(_:)), name: "settingsResetedNotification", object: nil)
	}
	
	func reset(notification: NSNotification) {
        #if DEBUG
            print("DisplaySettingsViewController, Received settingsResetedNotification")
        #endif
		self.showDescSwitch.on = settings.showDesc
		self.showNewsPictureSwitch.on = settings.showNewsPicture
	}
	
	func setTheme() {
		#if DEBUG
            print("DisplaySettingsViewController, setTheme()")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
		showDescLabel.textColor = Theme.textColor
		showDescDesc.textColor = Theme.textColor
		showNewsPictureLabel.textColor = Theme.textColor
		showNewsPictureDesc.textColor = Theme.textColor
		useSystemSizeLabel.textColor = Theme.textColor

		self.tableView.reloadData()
	}

	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("DisplaySettingsViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	func setContentSize() {
		showDescLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		showDescDesc.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
		showNewsPictureLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		showNewsPictureDesc.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
		
		tableView.reloadData()
	}
	
	func setContentSize(notification: NSNotification) {
		#if DEBUG
            print("DisplaySettingsViewController, Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}

	func renderPreview() {
		previewTitle.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
		previewAuthor.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
		previewDescription.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
		
		previewTitle.textColor = Theme.cellTitleColor
		previewAuthor.textColor = Theme.cellAuthorColor
		if (settings.showDesc) {
			previewDescription.hidden = false
		} else {
			previewDescription.hidden = true
		}
		previewDescription.textColor = Theme.cellDescriptionColor
		
		if settings.showNewsPicture {
			previewImageWidthConstraint.constant = 100
       		previewTitleLeadingConstraint.constant = 10
			previewImage.frame = CGRect(x: previewImage.frame.origin.x, y: previewImage.frame.origin.y, width: 100,height: 100)
		} else {
			previewImage.frame = CGRectZero
			previewImageWidthConstraint.constant = 0
        	previewTitleLeadingConstraint.constant = 0
		}
		
		previewContent.setNeedsLayout()
    	previewContent.layoutIfNeeded()
		self.tableView.reloadData()
	}

//	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//		let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
//    	if cell == self.previewCell {
//			return UITableViewAutomaticDimension
//		}
//		
//		return super.tableView(tableView, heightForRowAtIndexPath:indexPath)
//	}

	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
   		// Change the color of all cells
   		cell.backgroundColor = Theme.backgroundColor
		cell.textLabel!.textColor = Theme.cellTitleColor
		cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		cell.selectionStyle = .None
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))

		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor
		
		var sectionLabel: UILabel
		sectionLabel = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width/2, 25))
		sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
		sectionLabel.textColor = Theme.sectionTitleColor
		sectionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
		
		headerView.addSubview(sectionLabel)
		
    	return headerView
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
