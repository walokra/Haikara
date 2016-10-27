//
//  SettingsViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 7.7.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

	let viewName = "SettingsView"

	@IBOutlet weak var displayLabel: UILabel!
	
	@IBOutlet weak var useDarkLabel: UILabel!
	@IBOutlet weak var useDarkThemeSwitch: UISwitch!
	
	@IBOutlet weak var useMobileUrlLabel: UILabel!
	@IBOutlet weak var useMobileUrlDesc: UILabel!
	
	@IBOutlet weak var useReaderLabel: UILabel!
	@IBOutlet weak var useReaderDesc: UILabel!
	
	@IBOutlet weak var useChromeLabel: UILabel!
	@IBOutlet weak var useChromeDesc: UILabel!

	@IBOutlet weak var optOutAnalyticsLabel: UILabel!
	@IBOutlet weak var optOutAnalyticsDesc: UILabel!
	@IBOutlet weak var optOutAnalyticsSwitch: UISwitch!
	
	@IBOutlet weak var widgetCategoryLabel: UILabel!
	@IBOutlet weak var regionLabel: UILabel!

	@IBOutlet weak var useMobileUrlSwitch: UISwitch!
	@IBOutlet weak var useReaderViewSwitch: UISwitch!

	@IBOutlet weak var useChromeSwitch: UISwitch!
	@IBOutlet weak var useChromeCell: UITableViewCell!
	
	@IBOutlet weak var widgetCategoryDetailLabel: UILabel!
	@IBOutlet weak var regionDetailLabel: UILabel!

	let cancelText: String = NSLocalizedString("CANCEL_BUTTON", comment: "Text for cancel")
	let resetText: String = NSLocalizedString("RESET_BUTTON", comment: "Text for reset")

	@IBOutlet weak var resetButton: UIButton!
	@IBOutlet weak var resetLabel: UILabel!
	
	@IBAction func resetAction(sender: UIButton) {
		let alertController = UIAlertController(title: resetAlertTitle, message: resetAlertMessage, preferredStyle: .Alert)
		
		let cancelAction = UIAlertAction(title: cancelText, style: .Default, handler: nil)
		alertController.addAction(cancelAction)

		let destroyAction = UIAlertAction(title: resetText, style: .Destructive) { (action) in
			#if DEBUG
            	print ("destroyAction, action=\(action)")
        	#endif
			
			self.settings.resetToDefaults()
        
        	HighFiApi.getCategories(
        	    { (result) in
        	        self.settings.categories = result
					
        	        self.settings.categoriesByLang.updateValue(self.settings.categories, forKey: self.settings.region)
	                let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(self.settings.categoriesByLang as Dictionary<String, Array<Category>>)
        	        self.defaults!.setObject(archivedObject, forKey: "categoriesByLang")
					self.defaults!.synchronize()
					
                	// Send notification to inform favorite & hide views to refresh
                	NSNotificationCenter.defaultCenter().postNotificationName("settingsResetedNotification", object: nil, userInfo: nil)

                	return
            	}
            	, failureHandler: {(error)in
	                self.handleError(error)
    	        }
    	    )
        
        	self.listLanguages()
			
        	self.useMobileUrlSwitch.on = self.settings.useMobileUrl
        	self.useReaderViewSwitch.on = self.settings.useReaderView
		
			// All done
			let doneController = UIAlertController(title: self.resetMessageTitle, message: self.resetMessage, preferredStyle: .Alert)
        	let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        	doneController.addAction(OKAction)
			
			self.presentViewController(doneController, animated: true) {}
		}
		alertController.addAction(destroyAction)

		self.presentViewController(alertController, animated: true) {

		}
    }

    let settings = Settings.sharedInstance
	var defaults: NSUserDefaults?

    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    let resetMessageTitle: String = NSLocalizedString("SETTINGS_RESET_TITLE", comment: "")
    let resetMessage: String = NSLocalizedString("SETTINGS_RESET_MESSAGE", comment: "")
	let resetAlertTitle: String = NSLocalizedString("SETTINGS_RESET_ALERT_TITLE", comment: "")
    let resetAlertMessage: String = NSLocalizedString("SETTINGS_RESET_ALERT_MESSAGE", comment: "")
	
	@IBAction func unwindWithSelectedTodayCategory(segue:UIStoryboardSegue) {
//  		if let categoryPickerViewController = segue.sourceViewController as? CategoryPickerViewController,
//    		selectedTodayCategory = categoryPickerViewController.selectedTodayCategory {
//				#if DEBUG
//            		print ("selectedTodayCategory \(selectedTodayCategory)")
//        		#endif
//      		self.selectedTodayCategory = selectedTodayCategory
//  		}
	}

	@IBAction func unwindWithSelectedRegion(segue:UIStoryboardSegue) {
//  		if let regionPickerViewController = segue.sourceViewController as? RegionPickerViewController,
//    		selectedLanguage = regionPickerViewController.selectedLanguage {
//      		self.selectedLanguage = selectedLanguage
//  		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SelectDisplaySettings" {
//  			if let displaySettingsViewController = segue.destinationViewController as? DisplaySettingsViewController {
				#if DEBUG
            		print ("prepareForSegue: SelectDisplaySettings")
        		#endif
//  			}
		}
		
		if segue.identifier == "SelectTodayCategory" {
  			if let categoryPickerViewController = segue.destinationViewController as? CategoryPickerViewController {
				#if DEBUG
            		print ("prepareForSegue: SelectTodayCategory \(selectedTodayCategory)")
        		#endif
				categoryPickerViewController.categories = self.categories
    			categoryPickerViewController.selectedTodayCategory = selectedTodayCategory
  			}
		}
		
		if segue.identifier == "SelectLanguage" {
  			if let regionPickerViewController = segue.destinationViewController as? RegionPickerViewController {
				regionPickerViewController.languages = self.languages
    			regionPickerViewController.selectedLanguage = selectedLanguage
  			}
		}
	}

	@IBAction func useMobileUrlAction(sender: UISwitch) {
        settings.useMobileUrl = sender.on
        defaults!.setObject(settings.useMobileUrl, forKey: "useMobileUrl")
		defaults!.synchronize()
        #if DEBUG
            print ("useMobileUrl \(settings.useMobileUrl), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("useMobileUrl", category: "ui_Event", action: "useMobileUrl", label: "settings", value: (sender.on) ? 1 : 0)
	}

	@IBAction func useReaderViewAction(sender: UISwitch) {
		settings.useReaderView = sender.on
        defaults!.setObject(settings.useReaderView, forKey: "useReaderView")
		defaults!.synchronize()
        #if DEBUG
            print ("useReaderView \(settings.useReaderView), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("useReaderView", category: "ui_Event", action: "useReaderView", label: "settings", value: (sender.on) ? 1 : 0)
	}

	@IBAction func useDarkThemeAction(sender: UISwitch) {
		settings.useDarkTheme = sender.on
        defaults!.setObject(settings.useDarkTheme, forKey: "useDarkTheme")
		defaults!.synchronize()
        #if DEBUG
            print ("useDarkTheme \(settings.useDarkTheme), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("useDarkTheme", category: "ui_Event", action: "useDarkTheme", label: "settings", value: (sender.on) ? 1 : 0)

		NSNotificationCenter.defaultCenter().postNotificationName("themeChangedNotification", object: nil, userInfo: nil)
	}

	@IBAction func useChromeAction(sender: UISwitch) {
		settings.useChrome = sender.on
        defaults!.setObject(settings.useChrome, forKey: "useChrome")
		defaults!.synchronize()
        #if DEBUG
            print ("useChrome \(settings.useChrome), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("useChrome", category: "ui_Event", action: "useChrome", label: "settings", value: (sender.on) ? 1 : 0)
	}


	@IBAction func optOutAnalyticsAction(sender: UISwitch) {
		settings.optOutAnalytics = sender.on
        defaults!.setObject(settings.optOutAnalytics, forKey: "optOutAnalytics")
		defaults!.synchronize()
        #if DEBUG
            print ("optOutAnalyticsAction \(settings.optOutAnalytics), sender.on=\(sender.on)")
        #endif
		
		self.trackEvent("optOutAnalytics", category: "ui_Event", action: "optOutAnalytics", label: "settings", value: (sender.on) ? 1 : 0)
		
		NSNotificationCenter.defaultCenter().postNotificationName("optOutAnalyticsChangedNotification", object: nil, userInfo: nil)
	}

//	override func viewDidAppear(animated: Bool) {
//		super.viewDidAppear(animated)
//		sendScreenView(viewName)
//	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		listLanguages()
		self.categories = settings.categories
		setSelectedTodayCategory()
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
		if !OpenInChromeController.sharedInstance.isChromeInstalled() {
			useChromeCell.hidden = true
		}
		
        useMobileUrlSwitch.on = settings.useMobileUrl
        useReaderViewSwitch.on = settings.useReaderView
		useDarkThemeSwitch.on = settings.useDarkTheme
		useChromeSwitch.on = settings.useChrome
		optOutAnalyticsSwitch.on = settings.optOutAnalytics
    }
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setSelectedRegion(_:)), name: "regionChangedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setTodayCategories(_:)), name: "categoriesRefreshedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setTodayCategory(_:)), name: "todayCategoryChangedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}
	
	func setTheme() {
		#if DEBUG
            print("SettingsViewController, setTheme()")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
		displayLabel.textColor = Theme.textColor
		useMobileUrlLabel.textColor = Theme.textColor
		useMobileUrlDesc.textColor = Theme.textColor
		useReaderLabel.textColor = Theme.textColor
		useReaderDesc.textColor = Theme.textColor
		useDarkLabel.textColor = Theme.textColor
		useChromeLabel.textColor = Theme.textColor
		useChromeDesc.textColor = Theme.textColor
		optOutAnalyticsLabel.textColor = Theme.textColor
		optOutAnalyticsDesc.textColor = Theme.textColor

		widgetCategoryLabel.textColor = Theme.textColor
		resetLabel.textColor = Theme.textColor
		resetButton.setTitleColor(Theme.textColor, forState: .Normal)
		regionLabel.textColor = Theme.textColor
		
		self.tableView.reloadData()
	}

	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("SettingsViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	func setContentSize() {
		tableView.reloadData()
		
		displayLabel.font = settings.fontSizeLarge
		useMobileUrlLabel.font = settings.fontSizeLarge
		useMobileUrlDesc.font = settings.fontSizeMedium
		useReaderLabel.font = settings.fontSizeLarge
		useReaderDesc.font = settings.fontSizeMedium
		useDarkLabel.font = settings.fontSizeLarge
		optOutAnalyticsLabel.font = settings.fontSizeLarge
		optOutAnalyticsDesc.font = settings.fontSizeMedium

		widgetCategoryLabel.font = settings.fontSizeLarge
		regionLabel.font = settings.fontSizeLarge
		
		resetLabel.font = settings.fontSizeMedium
		resetButton.titleLabel!.font = settings.fontSizeMedium
	}
	
	func setContentSize(notification: NSNotification) {
		#if DEBUG
            print("DetailViewController, Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}
	
	func setSelectedRegion(notification: NSNotification) {
        #if DEBUG
            print("SettingsViewController, Received regionChangedNotification")
        #endif
		setSelectedRegion()
	}
	
	func setTodayCategories(notification: NSNotification) {
        #if DEBUG
            print("SettingsViewController, Received categoriesRefreshedNotification")
        #endif
		setSelectedRegion() //setSelectedTodayCategory()
	}
	
	func setTodayCategory(notification: NSNotification) {
        #if DEBUG
            print("SettingsViewController, Received todayCategoryChangedNotification")
        #endif
		self.selectedTodayCategory = self.settings.todayCategoryByLang[self.settings.region]
	}

	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
   		// Change the color of all cells
   		cell.backgroundColor = Theme.backgroundColor
		cell.textLabel!.textColor = Theme.cellTitleColor
		cell.textLabel!.font = settings.fontSizeLarge
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		cell.selectionStyle = .None
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    	let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    	if cell == self.useChromeCell {
			#if DEBUG
            	print("SettingsViewController, useChromeView HIDDEN")
			#endif
			return 0
		}
		
		return super.tableView(tableView, heightForRowAtIndexPath:indexPath)
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor
		
		var sectionLabel: UILabel
		sectionLabel = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width/2, 25))
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
	
	var categories = [Category]()
	var selectedTodayCategory: Category? {
		didSet {
    		widgetCategoryDetailLabel.text? = selectedTodayCategory!.title
		}
	}
	func setSelectedTodayCategory() {
        dispatch_async(dispatch_get_main_queue()) {
			if let categories: [Category] = self.settings.categoriesByLang[self.settings.region] {
				#if DEBUG
					print("SettingsViewController, setting categories for '\(self.settings.region)' from settings")
				#endif
			
				self.categories = categories
			}

			var defaultRowIndex = 0
			if (self.settings.todayCategoryByLang[self.settings.region] != nil) {
				for (index, element) in self.categories.enumerate() {
	            	let cat = element as Category
	            	if (cat.sectionID == self.settings.todayCategoryByLang[self.settings.region]?.sectionID) {
	            	    defaultRowIndex = index
	            	}
	        	}
			}
			
	        #if DEBUG
	            print("SettingsViewController, setTodayCategory=\(self.settings.todayCategoryByLang[self.settings.region]?.title), defaultRowIndex=\(defaultRowIndex)")
        	#endif
		    self.selectedTodayCategory = self.categories[defaultRowIndex]
			
			self.settings.todayCategoryByLang.updateValue(self.selectedTodayCategory!, forKey: self.settings.region)
        	let archivedTodayCategoryByLang = NSKeyedArchiver.archivedDataWithRootObject(self.settings.todayCategoryByLang as Dictionary<String, Category>)
        	self.defaults!.setObject(archivedTodayCategoryByLang, forKey: "todayCategoryByLang")
			self.defaults!.synchronize()
		}
    }
	
	var languages = [Language]()
	// The list of currently supported by the server.
    func listLanguages(){
//        #if DEBUG
//            print("SettingsViewController, listLanguages: self.settings.languages=\(self.settings.languages)")
//        #endif
		
        if !self.settings.languages.isEmpty {
            #if DEBUG
                print("SettingsViewController, listLanguages: getting languages from settings")
            #endif
            
            if let updated: NSDate = self.settings.languagesUpdated {
                let calendar = NSCalendar.currentCalendar()
                let comps = NSDateComponents()
                comps.day = 1
                let updatedPlusWeek = calendar.dateByAddingComponents(comps, toDate: updated, options: NSCalendarOptions())
                let today = NSDate()
                
                #if DEBUG
                    print("today=\(today), updated=\(updated), updatedPlusWeek=\(updatedPlusWeek)")
                #endif
                
                if updatedPlusWeek!.isLessThanDate(today) {
                    getLanguagesFromAPI()
                    return
                }
            }
            
            self.languages = self.settings.languages
            self.setSelectedRegion()
            return
        }
        
        #if DEBUG
            print("SettingsViewController, listLanguages: getting languages from API")
        #endif
        getLanguagesFromAPI()
    }
    
    func getLanguagesFromAPI() {
        HighFiApi.listLanguages(
            { (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    // Clear old entries
                    self.languages = result
                    self.settings.languages = result

//                  #if DEBUG
//                      println("supportedLanguages=\(self.supportedLanguages)")
//                  #endif
                    
                    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(self.settings.languages as Array<Language>)
                    
                    self.defaults!.setObject(archivedObject, forKey: "languages")
                    
                    self.settings.languagesUpdated = NSDate()
                    self.defaults!.setObject(self.settings.languagesUpdated, forKey: "languagesUpdated")
                    #if DEBUG
                        print("languages update, \(self.settings.languagesUpdated)")
                    #endif
                    
                    self.defaults!.synchronize()
                    
                    self.setSelectedRegion()
                    
                    return
                }
            }
            , failureHandler: {(error)in
                self.handleError(error)
            }
        )
    }
	
	var selectedLanguage: Language? {
		didSet {
    		regionDetailLabel.text? = selectedLanguage!.country
		}
	}
	func setSelectedRegion() {
        dispatch_async(dispatch_get_main_queue()) {
	        var defaultRowIndex = 0
	        for (index, element) in self.languages.enumerate() {
	            let lang = element as Language
	            if (lang.country == self.settings.region) {
	                defaultRowIndex = index
	            }
	        }
	        #if DEBUG
	            print("SettingsViewController, setSelectedRegion: region=\(self.settings.region), defaultRowIndex=\(defaultRowIndex)")
        	#endif
		    self.selectedLanguage = self.languages[defaultRowIndex]
			self.setSelectedTodayCategory()
		}
    }
	
	func handleError(error: String) {
        #if DEBUG
            print("SettingsViewController, handleError, error: \(error)")
        #endif
        let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true){}
    }

	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
