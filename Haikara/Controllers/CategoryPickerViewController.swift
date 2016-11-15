//
//  CategoryPickerViewController.swift
//  highkara
//
//  Created by Marko Wallin on 12.8.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {

	let viewName = "Settings_TodayCategoryPickerView"

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listRegionCell = "tableCell"
        }
    }
	
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	
    let settings = Settings.sharedInstance
	var defaults: NSUserDefaults?

    var categories = [Category]()
	var selectedTodayCategory: Category? {
    	didSet {
			print("categories=\(categories.count); selectedTodayCategory=\(selectedTodayCategory)")
			selectedTodayCategoryIndex = categories.indexOf(selectedTodayCategory!)
		}
  	}
  	var selectedTodayCategoryIndex: Int?

	override func viewDidLoad() {
        super.viewDidLoad()

		self.defaults = settings.defaults
		
		setTheme()
		sendScreenView(viewName)
    }
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tableView.backgroundColor = Theme.backgroundColor
		self.tableView.reloadData()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	  if segue.identifier == "SaveSelectedCategory" {
    	if let cell = sender as? UITableViewCell {
      		let indexPath = tableView.indexPathForCell(cell)
      		if let index = indexPath?.row {
        		selectedTodayCategory = categories[index]
      		}
    	}
	  }
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
  		return 1
	}
 
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  		return categories.count
	}
 
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  		let cell = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listRegionCell, forIndexPath: indexPath)
		
		let category: Category = self.categories[indexPath.row]
  		cell.textLabel?.text = category.title

		cell.textLabel!.textColor = Theme.cellTitleColor
		cell.textLabel!.font = settings.fontSizeXLarge
		
		if indexPath.row == selectedTodayCategoryIndex {
			cell.backgroundColor = Theme.selectedColor
			cell.accessibilityTraits = UIAccessibilityTraitSelected
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
  		if let index = selectedTodayCategoryIndex {
    		let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
			if (indexPath.row % 2 == 0) {
				cell?.backgroundColor = Theme.evenRowColor
			} else {
				cell?.backgroundColor = Theme.oddRowColor
			}
  		}
		
		settings.todayCategoryByLang.updateValue(selectedTodayCategory!, forKey: settings.region)
		selectedTodayCategory = categories[indexPath.row]
        let archivedTodayCategoryByLang = NSKeyedArchiver.archivedDataWithRootObject(settings.todayCategoryByLang as Dictionary<String, Category>)
        defaults!.setObject(archivedTodayCategoryByLang, forKey: "todayCategoryByLang")
		defaults!.synchronize()

		self.trackEvent("setTodayCategory", category: "ui_Event", action: "setTodayCategory", label: "settings", value: 1)

        NSNotificationCenter.defaultCenter().postNotificationName("todayCategoryChangedNotification", object: nil, userInfo: ["todayCategory": selectedTodayCategory!])
 
  		//update the checkmark for the current row
  		let cell = tableView.cellForRowAtIndexPath(indexPath)
		cell?.backgroundColor = Theme.selectedColor
	}

}

