//
//  SlideOutViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

protocol CategorySelectionDelegate: class {
    func categorySelected(newCategory: Category)
}

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
    
    let settings = Settings.sharedInstance

    var favoritesSelected: Bool = false
    @IBOutlet weak var favoritesButton: UIButton!
    @IBAction func favoritesButtonAction(sender: AnyObject) {
        if (favoritesSelected == false) {
            self.favoritesSelected = true
            createfavoritesIconButton(Theme.starColor)
        } else {
            self.favoritesSelected = false
            createfavoritesIconButton(Theme.tintColor)
        }
        getCategories()
    }
    
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonAction(sender: AnyObject) {
    }
	
    var categories = [Category]()
    var currentLanguage: String = "Finland"
	
	var favoritesItemTitle: String = NSLocalizedString("SETTINGS_FAVORITES_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    weak var delegate: CategorySelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Check for force touch feature, and add force touch/previewing capability.
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: tableView)
            }
        }
		
		setObservers()
		setTheme()
        
        let logo = UIImage(named: "app-logo_40x40.png")
        self.navigationItem.titleView = UIImageView(image: logo)
		
        currentLanguage = settings.region
        
        if self.categories.isEmpty {
            getCategories()
        }

        self.tableView!.delegate=self
        self.tableView.dataSource = self
    }
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setRegionCategory(_:)), name: "regionChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.updateSelectedCategories(_:)), name: "selectedCategoriesChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setRegionCategory(_:)), name: "settingsResetedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tableView.backgroundColor = Theme.backgroundColor
		
		createSettingsIconButton(Theme.tintColor)
		if settings.categoriesFavorited[settings.region] != nil {
            self.favoritesSelected = true
			createfavoritesIconButton(Theme.starColor)
        } else {
            self.favoritesSelected = false
            createfavoritesIconButton(Theme.tintColor)
        }
		self.tableView!.reloadData()
	}
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("MasterViewController, Received themeChangedNotification")
        #endif
		setTheme()
    }
	
    func setRegionCategory(notification: NSNotification) {
        #if DEBUG
            print("MasterView, Received regionChangedNotification")
            print(notification.userInfo)
        #endif
        
        getCategories()
    }
    
    func updateSelectedCategories(notification: NSNotification) {
        #if DEBUG
            print("MasterView, Received selectedCategoriesChangedNotification")
            print(notification.userInfo)
        #endif
        setCategories()
    }
    
    func setCategories() {
        // Adding always present categories: generic and top
        var cat = [Category]()
        let categoriesFavorited = settings.categoriesFavorited[settings.region]
		
		cat.append(Category(title: favoritesItemTitle, sectionID: 1001, depth: 1, htmlFilename: "favorites", selected: true))
		
        if favoritesSelected && categoriesFavorited != nil {
            #if DEBUG
                print("showing selected categories=\(categoriesFavorited)")
            #endif
            
            if categoriesFavorited!.isEmpty {
				cat.append(Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart, selected: true))
        		cat.append(Category(title: settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top", selected: true))
		
                self.categories = cat // + self.settings.categories
            } else {
                var filteredCategories = [Category]()
            
                self.settings.categories.forEach({ (category: Category) -> () in
                    if categoriesFavorited!.contains(category.sectionID) {
                        filteredCategories.append(category)
                    }
                })
            
                self.categories = cat + filteredCategories
            }
        } else {
			if categoriesFavorited != nil && !categoriesFavorited!.isEmpty {
				self.categories = cat + self.settings.categories
			} else {
				self.categories = cat + self.settings.categories
			}
        }

        self.tableView!.reloadData()
    }

    func getCategories(){
        // Get categories for selected region from settings' store
//        if self.settings.categoriesByLang[self.settings.region] != nil {

            if let categories: [Category] = self.settings.categoriesByLang[self.settings.region] {
                #if DEBUG
                    print("MasterView, getCategories: getting categories for '\(self.settings.region)' from settings")
                #endif
                
                if let updated: NSDate = self.settings.categoriesUpdatedByLang[self.settings.region] {
                    let calendar = NSCalendar.currentCalendar()
                    let comps = NSDateComponents()
                    comps.day = 1
                    let updatedPlusWeek = calendar.dateByAddingComponents(comps, toDate: updated, options: NSCalendarOptions())
                    let today = NSDate()
                    
                    #if DEBUG
                        print("today=\(today), updated=\(updated), updatedPlusWeek=\(updatedPlusWeek)")
                    #endif
                        
                    if updatedPlusWeek!.isLessThanDate(today) {
                        getCategoriesFromAPI()
                        return
                    }
                }
                
                self.settings.categories = categories
                self.categories = categories
                self.setCategories()
                
                NSNotificationCenter.defaultCenter().postNotificationName("categoriesRefreshedNotification", object: nil, userInfo: nil)

                return
            }
//        }
        
        #if DEBUG
            print("MasterView, getCategories: getting categories for lang from API")
        #endif
        // If categories for selected region is not found, fetch from API
        getCategoriesFromAPI()
    }
    
    func getCategoriesFromAPI() {
        HighFiApi.getCategories(
            { (result) in
                self.settings.categories = result
                self.categories = result
                
                self.settings.categoriesByLang.updateValue(self.settings.categories, forKey: self.settings.region)
                let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(self.settings.categoriesByLang as Dictionary<String, Array<Category>>)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(archivedObject, forKey: "categoriesByLang")
                
                self.settings.categoriesUpdatedByLang.updateValue(NSDate(), forKey: self.settings.region)
                defaults.setObject(self.settings.categoriesUpdatedByLang, forKey: "categoriesUpdatedByLang")
                #if DEBUG
                    print("categories updated, \(self.settings.categoriesUpdatedByLang[self.settings.region])")
                #endif
                
                defaults.synchronize()
                
//                #if DEBUG
//                    print("categoriesByLang=\(self.settings.categoriesByLang[self.settings.region])")
//                #endif
                
                self.setCategories()
                
                NSNotificationCenter.defaultCenter().postNotificationName("categoriesRefreshedNotification", object: nil, userInfo: nil)
                
                return
            }
            , failureHandler: {(error)in
                self.handleError(error)
            }
        )
    }
    
    func handleError(error: String) {
        #if DEBUG
            print("handleError, error: \(error)")
        #endif
        let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true){}
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
        cell.indentationLevel = (favoritesSelected) ? 0 : tableItem.depth - 1
		cell.textLabel!.textColor = Theme.textColor
		
		cell.selectedBackgroundView = Theme.selectedCellBackground
		
		if (indexPath.row % 2 == 0) {
			cell.backgroundColor = Theme.evenRowColor
		} else {
			cell.backgroundColor = Theme.oddRowColor
		}

		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        
        if let detailViewController = self.delegate as? DetailViewController {
            self.delegate?.categorySelected(selectedCategory)
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }

        splitViewController?.preferredDisplayMode = .PrimaryHidden
        splitViewController?.preferredDisplayMode = .Automatic
    }
	
	func createfavoritesIconButton(color: UIColor) {
        let buttonString = String.ionIconString("ion-ios-star-outline")
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("ionicons", fontSize: 32), range: NSRange(location: 0,length: 1))
        buttonStringAttributed.addAttribute(
        	NSForegroundColorAttributeName, value: color, range: NSRange(location: 0,length: 1)
        )
        
        favoritesButton.titleLabel?.textAlignment = .Center
        favoritesButton.titleLabel?.numberOfLines = 1
        favoritesButton.setAttributedTitle(buttonStringAttributed, forState: .Normal)
    }
	
	func createSettingsIconButton(color: UIColor) {
        let buttonString = String.ionIconString("ion-ios-gear-outline")
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("ionicons", fontSize: 32), range: NSRange(location: 0,length: 1))
        buttonStringAttributed.addAttribute(
            NSForegroundColorAttributeName,
            value: color,
            range: NSRange(location: 0,length: 1)
        )
        
        settingsButton.titleLabel?.textAlignment = .Center
        settingsButton.titleLabel?.numberOfLines = 1
        settingsButton.setAttributedTitle(buttonStringAttributed, forState: .Normal)
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
