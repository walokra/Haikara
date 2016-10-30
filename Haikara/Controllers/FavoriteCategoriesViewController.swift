//
//  FavoriteCategoriesViewController.swift
//  highkara
//
//  Created by Marko Wallin on 6.10.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

class FavoriteCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
	
	let viewName = "Settings_FavoriteCategoriesView"
	
    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
    
    let settings = Settings.sharedInstance
	var defaults: NSUserDefaults?
	
	var navigationItemTitle: String = NSLocalizedString("SETTINGS_FAVORITES_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")

	@IBOutlet weak var titleView: UIView!
	@IBOutlet weak var tableTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [Category]()
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
        self.categories = settings.categories
        
        #if DEBUG
            print("selected categories=\(settings.categoriesFavorited[settings.region])")
        #endif
        
        self.tableView!.delegate=self
        self.tableView.dataSource = self
    }
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoriteCategoriesViewController.setRegionCategory(_:)), name: "categoriesRefreshedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoriteCategoriesViewController.resetFavorited(_:)), name: "settingsResetedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoriteCategoriesViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FavoriteCategoriesViewController.setContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
		tableTitleLabel.textColor = Theme.textColor
		titleView.backgroundColor = Theme.backgroundColor
	}
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("FavoriteCategoriesView, Received themeChangedNotification")
        #endif
		setTheme()
		self.tableView.reloadData()
	}
	
	func setContentSize() {
		tableView.reloadData()
	}
	
	func setContentSize(notification: NSNotification) {
		#if DEBUG
            print("DetailViewController, Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}
	
    func setRegionCategory(notification: NSNotification) {
        #if DEBUG
            print("Received categoriesRefreshedNotification")
        #endif
        
        self.categories = settings.categories
        self.tableView!.reloadData()
    }
    
    func resetFavorited(notification: NSNotification) {
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
		cell.textLabel!.font = settings.fontSizeXLarge
        
        if (settings.categoriesFavorited[settings.region]?.indexOf(tableItem.sectionID) != nil) {
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
        if var langFavoriteCats = settings.categoriesFavorited[settings.region] {
            #if DEBUG
                print("langFavoriteCats=\(langFavoriteCats)")
            #endif
            
            if let index = langFavoriteCats.indexOf(selectedCategory.sectionID) {
                langFavoriteCats.removeAtIndex(index)
                removed = true
                self.categories[indexPath.row].selected = false
            }
            if (!removed) {
                langFavoriteCats.append(selectedCategory.sectionID)
                self.categories[indexPath.row].selected = true
            }
            settings.categoriesFavorited.updateValue(langFavoriteCats, forKey: settings.region)
        } else {
            settings.categoriesFavorited.updateValue([selectedCategory.sectionID], forKey: settings.region)
        }
        
        #if DEBUG
            print("langFavoriteCats=\(settings.categoriesFavorited[settings.region])")
        #endif
        
        defaults!.setObject(settings.categoriesFavorited, forKey: "categoriesFavorited")
		defaults!.synchronize()
		
        self.tableView!.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("selectedCategoriesChangedNotification", object: nil, userInfo: ["categories": "much categories"])
    }
    
    // stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
