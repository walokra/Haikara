//
//  MasterViewController.swift
//  Haikara
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Marko Wallin <mtw@iki.fi>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import SafariServices

protocol CategorySelectionDelegate: class {
    func categorySelected(_ newCategory: Category)
}

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
	
	let viewName = "CategoryView"
	
    let settings = Settings.sharedInstance
	var defaults: UserDefaults?
	// default section
	var selectedCategory: Category?

	var favoritesItemTitle: String = NSLocalizedString("SETTINGS_FAVORITES_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	var favoritesCategoryTitle: String = NSLocalizedString("FAVORITES_NONE_TITLE", comment: "Title for no favorite categories found")
	var favoritesCategoryMessage: String = NSLocalizedString("FAVORITES_NONE_DESC", comment: "Message for no favorite categories found")
	var settingsText: String = NSLocalizedString("SETTINGS", comment: "Settings")
	
    var favoritesSelected: Bool = false
    @IBOutlet weak var favoritesButton: UIButton!
    @IBAction func favoritesButtonAction(_ sender: AnyObject) {
		if settings.categoriesFavorited[settings.region] != nil {
			if (favoritesSelected == false) {
        	    self.favoritesSelected = true
        	    createfavoritesIconButton(Theme.starColor)
        	} else {
        	    self.favoritesSelected = false
        	    createfavoritesIconButton(Theme.tintColor)
        	}
			
			self.trackEvent("favoritesButtonAction", category: "ui_Event", action: "favoritesButtonAction", label: "main", value: (favoritesSelected) ? 1 : 0)
			
        	getCategoriesFromSettingOrAPI()
		} else {
			let alertController = UIAlertController(title: favoritesCategoryTitle, message: favoritesCategoryMessage, preferredStyle: .alert)
		
			let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
			alertController.addAction(okAction)

			let gotoSettingsAction = UIAlertAction(title: settingsText, style: .default) { (action) in
				if let settingsTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "SettingsTabBarController") as? UITabBarController {
					settingsTabBarController.selectedIndex = 1
					self.navigationController!.pushViewController(settingsTabBarController, animated: true)
				}
			}
			alertController.addAction(gotoSettingsAction)

			self.present(alertController, animated: true){}
		}
    }
	
//	override var preferredStatusBarStyle: UIStatusBarStyle {
//        return Theme.statusBarStyle
//    }
	
	@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonAction(_ sender: AnyObject) {
    }
	
    var categories = [Category]()
    var currentLanguage: String = "Finland"
	
    weak var delegate: CategorySelectionDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		let uuid = UUID().uuidString
		let hmacResult: String = uuid.hmac(HMACAlgorithm.sha256, key: uuid)
		print("hmacResult=\(hmacResult)")
		
		self.selectedCategory = Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart, highlight: false, selected: true)
		
		if let deviceID = defaults!.string(forKey: "deviceID") {
			settings.deviceID = deviceID
        } else {
            defaults!.set(hmacResult, forKey: "deviceID")
            settings.deviceID = defaults!.string(forKey: "deviceID")!
            #if DEBUG
                print("Setting new deviceID value: \(settings.deviceID)")
            #endif
        }
		
		// Check for force touch feature, and add force touch/previewing capability.
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: tableView)
		}
		
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
        let logo = UIImage(named: "app-logo_40x40.png")
        self.navigationItem.titleView = UIImageView(image: logo)
		
        currentLanguage = settings.region
        
        if self.categories.isEmpty {
            getCategoriesFromSettingOrAPI()
        }

        self.tableView!.delegate = self
        self.tableView.dataSource = self
    }

	func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.setRegionCategory(_:)), name: .regionChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.updateSelectedCategories(_:)), name: .selectedCategoriesChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.setRegionCategory(_:)), name: .settingsResetedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.setTheme(_:)), name: .themeChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.setContentSize(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
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
	
	@objc func setTheme(_ notification: Notification) {
        #if DEBUG
            print("MasterViewController, Received themeChangedNotification")
        #endif
		setTheme()
    }
	
	func setContentSize() {
		self.tableView.reloadData()
	}
	
	@objc func setContentSize(_ notification: Notification) {
		#if DEBUG
            print("Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}
	
    @objc func setRegionCategory(_ notification: Notification) {
        #if DEBUG
            print("MasterView, Received regionChangedNotification")
            print(notification.userInfo as Any)
        #endif
        
        getCategoriesFromSettingOrAPI()
    }

    @objc func updateSelectedCategories(_ notification: Notification) {
        #if DEBUG
            print("MasterView, Received selectedCategoriesChangedNotification")
            print(notification.userInfo as Any)
        #endif
        setCategories()
    }
    
    func setCategories() {
        // Adding always present categories: generic and top
        var cat = [Category]()
		if let categoriesFavorited = settings.categoriesFavorited[settings.region] {
			cat.append(Category(title: favoritesItemTitle, sectionID: 1001, depth: 1, htmlFilename: "favorites", highlight: false, selected: true))
			if favoritesSelected {
				#if DEBUG
                	print("showing selected categories=\(categoriesFavorited)")
           	 	#endif
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

    func getCategoriesFromSettingOrAPI(){
        // Get categories for selected region from settings' store
		if let categories: [Category] = self.settings.categoriesByLang[self.settings.region] {
			#if DEBUG
				print("MasterView, getCategoriesFromSettingOrAPI: getting categories for '\(self.settings.region)' from settings")
			#endif
                
			if let updated: Date = self.settings.categoriesUpdatedByLang[self.settings.region] {
				let calendar = Calendar.current
				var comps = DateComponents()
				comps.minute = 30
				let updatedPlusThirty = (calendar as NSCalendar).date(byAdding: comps, to: updated, options: NSCalendar.Options())
				let today = Date()
                    
				#if DEBUG
					print("today=\(today), updated=\(updated), updatedPlusThirty=\(String(describing: updatedPlusThirty))")
				#endif
                        
				if updatedPlusThirty!.isLessThanDate(today) {
					getCategoriesFromAPI()
					return
				}
			}
                
			self.settings.categories = categories
			self.categories = categories
			self.setCategories()
                
			NotificationCenter.default.post(name: .categoriesRefreshedNotification, object: nil, userInfo: nil)

			return
		}
        
        #if DEBUG
            print("MasterView, getCategoriesFromSettingOrAPI: getting categories for lang from API")
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
                do {
                    let archivedObject = try NSKeyedArchiver.archivedData(withRootObject: self.settings.categoriesByLang as Dictionary<String, Array<Category>>, requiringSecureCoding: false)
                    self.defaults!.set(archivedObject, forKey: "categoriesByLang")
                }
                catch {
                    #if DEBUG
                        print("error: \(error)")
                    #endif
                }
                
                self.settings.categoriesUpdatedByLang.updateValue(Date(), forKey: self.settings.region)
                self.defaults!.set(self.settings.categoriesUpdatedByLang, forKey: "categoriesUpdatedByLang")
                #if DEBUG
                    print("categories updated, \(String(describing: self.settings.categoriesUpdatedByLang[self.settings.region]))")
                #endif
                
                self.defaults!.synchronize()
                
//                #if DEBUG
//                    print("categoriesByLang=\(self.settings.categoriesByLang[self.settings.region])")
//                #endif
                
                self.setCategories()
                
                NotificationCenter.default.post(name: .categoriesRefreshedNotification, object: nil, userInfo: nil)
                
                return
            }
            , failureHandler: {(error)in
                self.handleError(error, title: self.errorTitle)
            }
        )
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: MainStoryboard.TableViewCellIdentifiers.listCategoryCell, for: indexPath) 
		
        let tableItem: Category = categories[indexPath.row] as Category
        cell.textLabel!.text = tableItem.title
        cell.indentationLevel = (favoritesSelected) ? 0 : ((tableItem.depth == 1) ? 0 : tableItem.depth + 1)
		cell.textLabel!.textColor = Theme.textColor
		cell.textLabel!.font = settings.fontSizeXLarge

		if (indexPath.row % 2 == 0) {
			cell.backgroundColor = (tableItem.highlight) ? Theme.tintColor : Theme.evenRowColor
		} else {
			cell.backgroundColor = (tableItem.highlight) ? Theme.tintColor : Theme.oddRowColor
		}

		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
	    let selectionColor = UIView() as UIView
	    selectionColor.backgroundColor = Theme.tintColor
	    cell.selectedBackgroundView = selectionColor
	}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {	
        self.selectedCategory = self.categories[indexPath.row]
		
        if let detailViewController = self.delegate as? DetailViewController {
            self.delegate?.categorySelected(self.selectedCategory!)
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }

        splitViewController?.preferredDisplayMode = .primaryHidden
        splitViewController?.preferredDisplayMode = .automatic
    }
	
	func createfavoritesIconButton(_ color: UIColor) {
        let buttonString = String.ionIconString("ion-ios-star-outline")
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSAttributedString.Key.font:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSAttributedString.Key.font, value: UIFont.iconFontOfSize("ionicons", fontSize: 32), range: NSRange(location: 0,length: 1))
        buttonStringAttributed.addAttribute(
        	NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: 0,length: 1)
        )
        
        favoritesButton.titleLabel?.textAlignment = .center
        favoritesButton.titleLabel?.numberOfLines = 1
        favoritesButton.setAttributedTitle(buttonStringAttributed, for: UIControl.State())
    }
	
	func createSettingsIconButton(_ color: UIColor) {
        let buttonString = String.ionIconString("ion-ios-gear-outline")
        let buttonStringAttributed = NSMutableAttributedString(string: buttonString, attributes: [NSAttributedString.Key.font:UIFont(name: "HelveticaNeue", size: 11.00)!])
        buttonStringAttributed.addAttribute(NSAttributedString.Key.font, value: UIFont.iconFontOfSize("ionicons", fontSize: 32), range: NSRange(location: 0,length: 1))
        buttonStringAttributed.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: color,
            range: NSRange(location: 0,length: 1)
        )
        
        settingsButton.titleLabel?.textAlignment = .center
        settingsButton.titleLabel?.numberOfLines = 1
        settingsButton.setAttributedTitle(buttonStringAttributed, for: UIControl.State())
	}
	
	override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    // stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
