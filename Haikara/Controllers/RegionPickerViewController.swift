//
//  RegionPickerViewController.swift
//  highkara
//
//  Created by Marko Wallin on 12.8.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

class RegionPickerViewController: UITableViewController {

	let viewName = "Settings_RegionPickerView"

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listRegionCell = "tableCell"
        }
    }
	
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	
    let settings = Settings.sharedInstance
    var defaults: NSUserDefaults?

    var languages = [Language]()
	var selectedLanguage: Language? {
    	didSet {
			selectedLanguageIndex = languages.indexOf(selectedLanguage!)
		}
  	}
  	var selectedLanguageIndex: Int?
	
//	override func viewDidAppear(animated: Bool) {
//		super.viewDidAppear(animated)
//		sendScreenView(viewName)
//	}

	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		setTheme()
		sendScreenView(viewName)
    }
	
	func setTheme() {
		#if DEBUG
            print("RegionPickerViewController, setTheme()")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tableView.backgroundColor = Theme.backgroundColor
		self.tableView.reloadData()
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	  if segue.identifier == "SaveSelectedLanguage" {
    	if let cell = sender as? UITableViewCell {
      		let indexPath = tableView.indexPathForCell(cell)
      		if let index = indexPath?.row {
        		selectedLanguage = languages[index]
      		}
    	}
	  }
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  		return 1
	}
 
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  		return languages.count
	}
 
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  		let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listRegionCell, forIndexPath: indexPath)
		
		let lang: Language = self.languages[indexPath.row]
  		cell.textLabel?.text = lang.country
		
//		if indexPath.row == selectedLanguageIndex {
//    		cell.accessoryType = .Checkmark
//  		} else {
//    		cell.accessoryType = .None
//		}

		cell.textLabel!.textColor = Theme.cellTitleColor
		if indexPath.row == selectedLanguageIndex {
			cell.backgroundColor = Theme.selectedColor
		} else {
			if (indexPath.row % 2 == 0) {
				cell.backgroundColor = Theme.evenRowColor
			} else {
				cell.backgroundColor = Theme.oddRowColor
			}
		}
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		
  		return cell
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
 
  		//Other row is selected - need to deselect it
  		if let index = selectedLanguageIndex {
    		let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
    		cell?.accessoryType = .None
  		}
 
  		selectedLanguage = languages[indexPath.row]
		settings.region = selectedLanguage!.country
        settings.useToRetrieveLists = selectedLanguage!.useToRetrieveLists
        settings.mostPopularName = selectedLanguage!.mostPopularName
        settings.latestName = selectedLanguage!.latestName
        settings.domainToUse = selectedLanguage!.domainToUse
        settings.genericNewsURLPart = selectedLanguage!.genericNewsURLPart
        #if DEBUG
            print ("selected region = \(settings.region)")
        #endif

        defaults!.setObject(settings.region, forKey: "region")
        defaults!.setObject(settings.useToRetrieveLists, forKey: "useToRetrieveLists")
        defaults!.setObject(settings.mostPopularName, forKey: "mostPopularName")
        defaults!.setObject(settings.latestName, forKey: "latestName")
        defaults!.setObject(settings.domainToUse, forKey: "domainToUse")
        defaults!.setObject(settings.genericNewsURLPart, forKey: "genericNewsURLPart")
		
		defaults!.synchronize()

		self.trackEvent("setRegion", category: "ui_Event", action: "setRegion", label: "settings", value: 1)

        NSNotificationCenter.defaultCenter().postNotificationName("regionChangedNotification", object: nil, userInfo: ["region": selectedLanguage!])
 
  		//update the checkmark for the current row
  		let cell = tableView.cellForRowAtIndexPath(indexPath)
  		cell?.accessoryType = .Checkmark
	}
	
	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
