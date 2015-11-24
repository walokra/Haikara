//
//  HideCategoryViewController.swift
//  highkara
//
//  Created by Marko Wallin on 20.10.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

class HideCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
	
	
	@IBOutlet weak var tableTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let settings = Settings.sharedInstance
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		setObservers()
		setTheme()
        
        self.categories = settings.categories
        
        #if DEBUG
            print("categories hidden=\(settings.categoriesHidden[settings.region])")
        #endif
            
        self.tableView!.delegate=self
        self.tableView.dataSource = self
    }
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setRegionCategory:", name: "categoriesRefreshedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetHidden:", name: "settingsResetedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "setTheme:", name: "themeChangedNotification", object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
		tableTitleLabel.textColor = Theme.textColor
		tableTitleLabel.backgroundColor = Theme.backgroundColor
	}
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("HideCategoriesView, Received themeChangedNotification")
        #endif
		setTheme()
	}
    
    func setRegionCategory(notification: NSNotification) {
        #if DEBUG
            print("Received categoriesRefreshedNotification")
        #endif
        
        self.categories = settings.categories
        self.tableView!.reloadData()
    }
    
    func resetHidden(notification: NSNotification) {
        #if DEBUG
            print("Received settingsResetedNotification")
        #endif
        
        self.categories = settings.categories
        self.tableView!.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listCategoryCell, forIndexPath: indexPath)
        
        let tableItem: Category = categories[indexPath.row] as Category
        
        cell.textLabel!.text = tableItem.title
        cell.indentationLevel = tableItem.depth
		cell.textLabel!.textColor = Theme.cellTitleColor
        
        if (settings.categoriesHidden[settings.region]?.indexOf(tableItem.sectionID) != nil) {
            cell.backgroundColor = Theme.selectedColor
        } else {
			if (indexPath.row % 2 == 0) {
				cell.backgroundColor = Theme.evenRowColor
			} else {
				cell.backgroundColor = Theme.oddRowColor
			}
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        #if DEBUG
            print("didSelectRowAtIndexPath, selectedCategory=\(selectedCategory.title), \(selectedCategory.sectionID)")
        #endif
        
        var removed: Bool = false
        if var catHiddenForLang = settings.categoriesHidden[settings.region] {
            #if DEBUG
                print("catHiddenForLang=\(catHiddenForLang)")
            #endif
            
            if let index = catHiddenForLang.indexOf(selectedCategory.sectionID) {
//                print("Removing item at index \(index)")
                catHiddenForLang.removeAtIndex(index)
                removed = true
                self.categories[indexPath.row].selected = false
            }
            if (!removed) {
//                print("Adding item to hidden categories, \(selectedCategory.sectionID)")
                catHiddenForLang.append(selectedCategory.sectionID)
                self.categories[indexPath.row].selected = true
            }
            settings.categoriesHidden.updateValue(catHiddenForLang, forKey: settings.region)
        } else {
//            print("Creating new key for language categories, \(settings.region)")
            settings.categoriesHidden.updateValue([selectedCategory.sectionID], forKey: settings.region)
        }
        
        #if DEBUG
            print("categoriesHidden[region]=\(settings.categoriesHidden[settings.region])")
        #endif
        
        defaults.setObject(settings.categoriesHidden, forKey: "categoriesHidden")
        self.tableView!.reloadData()
    }
    
    // stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
