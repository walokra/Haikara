//
//  SlideOutViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import SafariServices

protocol CategorySelectionDelegate: class {
    func categorySelected(newCategory: Category)
}

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
	
	let viewName = "CategoryView"
	
    let settings = Settings.sharedInstance
	var defaults: NSUserDefaults?

	var favoritesItemTitle: String = NSLocalizedString("SETTINGS_FAVORITES_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	var favoritesCategoryTitle: String = NSLocalizedString("FAVORITES_NONE_TITLE", comment: "Title for no favorite categories found")
	var favoritesCategoryMessage: String = NSLocalizedString("FAVORITES_NONE_DESC", comment: "Message for no favorite categories found")
	var settingsText: String = NSLocalizedString("SETTINGS", comment: "Settings")
	
    var favoritesSelected: Bool = false
    @IBOutlet weak var favoritesButton: UIButton!
    @IBAction func favoritesButtonAction(sender: AnyObject) {
		if settings.categoriesFavorited[settings.region] != nil {
			if (favoritesSelected == false) {
        	    self.favoritesSelected = true
        	    createfavoritesIconButton(Theme.starColor)
        	} else {
        	    self.favoritesSelected = false
        	    createfavoritesIconButton(Theme.tintColor)
        	}
			
			self.trackEvent("favoritesButtonAction", category: "ui_Event", action: "favoritesButtonAction", label: "main", value: (favoritesSelected) ? 1 : 0)
			
        	getCategories()
		} else {
			let alertController = UIAlertController(title: favoritesCategoryTitle, message: favoritesCategoryMessage, preferredStyle: .Alert)
		
			let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
			alertController.addAction(okAction)

			let gotoSettingsAction = UIAlertAction(title: settingsText, style: .Default) { (action) in
				if let settingsTabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsTabBarController") as? UITabBarController {
					settingsTabBarController.selectedIndex = 1
					self.navigationController!.pushViewController(settingsTabBarController, animated: true)
				}
			}
			alertController.addAction(gotoSettingsAction)

			self.presentViewController(alertController, animated: true){}
		}
    }
    
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonAction(sender: AnyObject) {
    }
	
    var categories = [Category]()
    var currentLanguage: String = "Finland"
	
    weak var delegate: CategorySelectionDelegate?
	
//	override func viewDidAppear(animated: Bool) {
//		super.viewDidAppear(animated)
//		sendScreenView(viewName)
//	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		// Check for force touch feature, and add force touch/previewing capability.
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: tableView)
            }
        }
		
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
        let logo = UIImage(named: "app-logo_40x40.png")
        self.navigationItem.titleView = UIImageView(image: logo)
		
        currentLanguage = settings.region
        
        if self.categories.isEmpty {
            getCategories()
        }

        self.tableView!.delegate = self
        self.tableView.dataSource = self
		
		// Reset delegates url after we've opened it 
    	let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
    	if (delegate?.openUrl) != nil {
        	delegate?.openUrl = nil
    	}
		
		let tracker = GAI.sharedInstance().defaultTracker
		tracker.set(kGAIScreenName, value: viewName)
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker.send(builder.build() as [NSObject : AnyObject])
    }
	
	func handleOpenURL(notification:NSNotification){
    	if let url = notification.object as? String {
			let webURL = NSURL(string: url)

			#if DEBUG
				print("handleOpenURL. webURL=\(webURL)")
			#endif
			
			if #available(iOS 9.0, *) {
				let svc = SFSafariViewController(URL: webURL!, entersReaderIfAvailable: settings.useReaderView)
				svc.view.tintColor = Theme.tintColor
				self.presentViewController(svc, animated: true, completion: nil)
				
				// TODO
//				HighFiApi.trackNewsClick(entry.clickTrackingLink)
			} else {
				// Fallback on earlier versions
			}
    	}
	}
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setRegionCategory(_:)), name: "regionChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.updateSelectedCategories(_:)), name: "selectedCategoriesChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setRegionCategory(_:)), name: "settingsResetedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.handleOpenURL(_:)), name:"handleOpenURL", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.setContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tableView.backgroundColor = Theme.backgroundColor
		
		createSettingsIconButton(Theme.tintColor)
		if settings.categoriesFavorited[settings.region] != nil && self.favoritesSelected {
			createfavoritesIconButton(Theme.starColor)
        } else {
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
	
	func setContentSize() {
		self.tableView.reloadData()
	}
	
	func setContentSize(notification: NSNotification) {
		#if DEBUG
            print("Received UIContentSizeCategoryDidChangeNotification")
        #endif
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
		if let categoriesFavorited = settings.categoriesFavorited[settings.region] {
			cat.append(Category(title: favoritesItemTitle, sectionID: 1001, depth: 1, htmlFilename: "favorites", selected: true))
			if favoritesSelected {
				#if DEBUG
                	print("showing selected categories=\(categoriesFavorited)")
           	 	#endif
//					cat.append(Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart, selected: true))
//	        		cat.append(Category(title: settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top", selected: true))
   	            var filteredCategories = [Category]()
					
   	            self.settings.categories.forEach({ (category: Category) -> () in
   	                if categoriesFavorited.contains(category.sectionID) {
   	                    filteredCategories.append(category)
   	                }
				})
				
				self.categories = cat + filteredCategories
			} else {
				self.categories = cat + self.settings.categories
			}
		} else {
			self.categories = self.settings.categories
		}
		
        self.tableView!.reloadData()
    }

    func getCategories(){
        // Get categories for selected region from settings' store
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
				self.defaults!.setObject(archivedObject, forKey: "categoriesByLang")
                
                self.settings.categoriesUpdatedByLang.updateValue(NSDate(), forKey: self.settings.region)
                self.defaults!.setObject(self.settings.categoriesUpdatedByLang, forKey: "categoriesUpdatedByLang")
                #if DEBUG
                    print("categories updated, \(self.settings.categoriesUpdatedByLang[self.settings.region])")
                #endif
                
                self.defaults!.synchronize()
                
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
            print("MasterViewController, handleError, error: \(error)")
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
		cell.textLabel!.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
		
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
