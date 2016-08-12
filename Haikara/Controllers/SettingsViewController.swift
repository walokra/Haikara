//
//  SettingsViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 7.7.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

	@IBOutlet weak var showDescLabel: UILabel!
	@IBOutlet weak var showDescDesc: UILabel!
	@IBOutlet weak var useMobileUrlLabel: UILabel!
	@IBOutlet weak var useMobileUrlDesc: UILabel!
	
	@IBOutlet weak var useReaderLabel: UILabel!
	@IBOutlet weak var useReaderDesc: UILabel!
	@IBOutlet weak var useDarkLabel: UILabel!
	@IBOutlet weak var regionLabel: UILabel!
	
	@IBOutlet weak var showDescSwitch: UISwitch!
	@IBOutlet weak var useMobileUrlSwitch: UISwitch!
	@IBOutlet weak var useReaderViewSwitch: UISwitch!
	@IBOutlet weak var useDarkThemeSwitch: UISwitch!
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
                
    	            let defaults = NSUserDefaults.standardUserDefaults()
        	        defaults.setObject(archivedObject, forKey: "categoriesByLang")
            	    defaults.synchronize()
                
                	// Send notification to inform favorite & hide views to refresh
                	NSNotificationCenter.defaultCenter().postNotificationName("settingsResetedNotification", object: nil, userInfo: nil)

                	return
            	}
            	, failureHandler: {(error)in
	                self.handleError(error)
    	        }
    	    )
        
        	self.listLanguages()
			
        	self.showDescSwitch.on = self.settings.showDesc
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

    var defaults = NSUserDefaults.standardUserDefaults()

    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    let resetMessageTitle: String = NSLocalizedString("SETTINGS_RESET_TITLE", comment: "")
    let resetMessage: String = NSLocalizedString("SETTINGS_RESET_MESSAGE", comment: "")
	let resetAlertTitle: String = NSLocalizedString("SETTINGS_RESET_ALERT_TITLE", comment: "")
    let resetAlertMessage: String = NSLocalizedString("SETTINGS_RESET_ALERT_MESSAGE", comment: "")
	
	@IBAction func unwindWithSelectedRegion(segue:UIStoryboardSegue) {
  		if let regionPickerViewController = segue.sourceViewController as? RegionPickerViewController,
    		selectedLanguage = regionPickerViewController.selectedLanguage {
      		self.selectedLanguage = selectedLanguage
  		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SelectLanguage" {
  			if let regionPickerViewController = segue.destinationViewController as? RegionPickerViewController {
				regionPickerViewController.languages = languages
    			regionPickerViewController.selectedLanguage = selectedLanguage
  			}
		}
	}

	@IBAction func showDescAction(sender: UISwitch) {
		settings.showDesc = sender.on
        defaults.setObject(settings.showDesc, forKey: "showDesc")
        #if DEBUG
            print ("showDesc \(settings.showDesc), sender.on=\(sender.on)")
        #endif
	}

	@IBAction func useMobileUrlAction(sender: UISwitch) {
        settings.useMobileUrl = sender.on
        defaults.setObject(settings.useMobileUrl, forKey: "useMobileUrl")
        #if DEBUG
            print ("useMobileUrl \(settings.useMobileUrl), sender.on=\(sender.on)")
        #endif
	}

	@IBAction func useReaderViewAction(sender: UISwitch) {
		settings.useReaderView = sender.on
        defaults.setObject(settings.useReaderView, forKey: "useReaderView")
        #if DEBUG
            print ("useReaderView \(settings.useReaderView), sender.on=\(sender.on)")
        #endif
	}

	@IBAction func useDarkThemeAction(sender: UISwitch) {
		settings.useDarkTheme = sender.on
        defaults.setObject(settings.useDarkTheme, forKey: "useDarkTheme")

        #if DEBUG
            print ("useDarkTheme \(settings.useDarkTheme), sender.on=\(sender.on)")
        #endif
		
		NSNotificationCenter.defaultCenter().postNotificationName("themeChangedNotification", object: nil, userInfo: nil)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		listLanguages()
		setObservers()
		setTheme()
		
        showDescSwitch.on = settings.showDesc
        useMobileUrlSwitch.on = settings.useMobileUrl
        useReaderViewSwitch.on = settings.useReaderView
		useDarkThemeSwitch.on = settings.useDarkTheme		
    }
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
	}
	
	func setTheme() {
		#if DEBUG
            print("SettingsViewController, setTheme()")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
		showDescLabel.textColor = Theme.textColor
		showDescDesc.textColor = Theme.textColor
		useMobileUrlLabel.textColor = Theme.textColor
		useMobileUrlDesc.textColor = Theme.textColor
		useReaderLabel.textColor = Theme.textColor
		useReaderDesc.textColor = Theme.textColor
		useDarkLabel.textColor = Theme.textColor
		resetLabel.textColor = Theme.textColor
		resetButton.setTitleColor(Theme.textColor, forState: .Normal)
//		countryPicker.backgroundColor = UIColor.darkGrayColor()
		regionLabel.textColor = Theme.textColor
		
//		self.countryPicker.reloadAllComponents()

//		self.tabBarController?.tabBar.barStyle = Theme.barStyle

		self.tableView.reloadData()
	}

	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("SettingsViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
   		// Change the color of all cells
   		cell.backgroundColor = Theme.backgroundColor
		cell.textLabel!.textColor = Theme.cellTitleColor
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		cell.selectionStyle = .None
	}

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 44))

		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor
		
		var sectionLabel: UILabel
		sectionLabel = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width/2, 22))
		sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
		sectionLabel.textColor = Theme.sectionTitleColor
		sectionLabel.font = UIFont.systemFontOfSize(17)
		headerView.addSubview(sectionLabel)
		
    	return headerView
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	var languages = [Language]()
	var selectedLanguage: Language? {
		didSet {
    		regionDetailLabel.text? = selectedLanguage!.country
		}
	}

	// The list of currently supported by the server. 
    func listLanguages(){
        #if DEBUG
            print("regionPickerView, listLanguages: self.settings.languages=\(self.settings.languages)")
        #endif
        
        if !self.settings.languages.isEmpty {
            #if DEBUG
                print("regionPickerView, listLanguages: getting languages from settings")
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
            print("regionPickerView, listLanguages: getting languages from API")
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
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    defaults.setObject(archivedObject, forKey: "languages")
                    
                    self.settings.languagesUpdated = NSDate()
                    defaults.setObject(self.settings.languagesUpdated, forKey: "languagesUpdated")
                    #if DEBUG
                        print("languages update, \(self.settings.languagesUpdated)")
                    #endif
                    
                    defaults.synchronize()
                    
                    self.setSelectedRegion()
                    
                    return
                }
            }
            , failureHandler: {(error)in
                self.handleError(error)
            }
        )
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
	            print("regionPickerView, setSelectedRegion: region=\(self.settings.region), defaultRowIndex=\(defaultRowIndex)")
        	#endif
		    self.selectedLanguage = self.languages[defaultRowIndex]
		}
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
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
