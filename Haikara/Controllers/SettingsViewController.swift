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
	
	var regionPickerHidden = false
	
	// Close picker when touching somewhere, not necessary to select value
	@IBAction func viewTapped(sender: AnyObject) {
		self.view.endEditing(true)
	}

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

//   	var countryPicker: UIPickerView!
    let settings = Settings.sharedInstance

    var defaults = NSUserDefaults.standardUserDefaults()
    
    var languages = [Language]()
    
    var navigationItemTitle: String = NSLocalizedString("SETTINGS_TITLE", comment: "Title for settings view")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    let resetMessageTitle: String = NSLocalizedString("SETTINGS_RESET_TITLE", comment: "")
    let resetMessage: String = NSLocalizedString("SETTINGS_RESET_MESSAGE", comment: "")
	let resetAlertTitle: String = NSLocalizedString("SETTINGS_RESET_ALERT_TITLE", comment: "")
    let resetAlertMessage: String = NSLocalizedString("SETTINGS_RESET_ALERT_MESSAGE", comment: "")
	
	let darkThemeTitle: String = NSLocalizedString("SETTINGS_DARK_THEME", comment: "")

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
		
//		countryPicker = UIPickerView()

		setObservers()
		setTheme()
		setText()
		
//		self.tabBarController!.title = navigationItemTitle
//        self.navigationItem.title = navigationItemTitle
		
//        listLanguages()
		
        showDescSwitch.on = settings.showDesc
        useMobileUrlSwitch.on = settings.useMobileUrl
        useReaderViewSwitch.on = settings.useReaderView
		useDarkThemeSwitch.on = settings.useDarkTheme
		
//        countryPicker.dataSource = self
//        countryPicker.delegate = self

//		self.tableView!.delegate = self
//        self.tableView.dataSource = self
    }
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
	}
	
	func setText() {
//		useDarkLabel.text = darkThemeTitle
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

//	override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//		
//		let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//    	header.textLabel!.textColor = Theme.sectionTitleColor
//    }

//	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//    	if regionPickerHidden && indexPath.section == 0 && indexPath.row == 1 {
//        	return 0
//    	}
//    	else {
//    	    return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
//    	}
//	}
//	
//	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    	if indexPath.section == 0 && indexPath.row == 4 {
//        	toggleRegionPicker()
//    	}
//	}
//	
//	func toggleRegionPicker() {
//    	regionPickerHidden = !regionPickerHidden
// 
//    	tableView.beginUpdates()
//    	tableView.endUpdates()
//	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 5
    }
	
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return self.languages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.languages[row].country
    }
	
	func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
	    return NSAttributedString(string: self.languages[row].country, attributes: [NSForegroundColorAttributeName:Theme.textColor])
	}
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
//		self.regionDetailLabel.text = languages[row].country
		
        let selectedRegion = self.languages[row]
        settings.region = selectedRegion.country
        settings.useToRetrieveLists = selectedRegion.useToRetrieveLists
        settings.mostPopularName = selectedRegion.mostPopularName
        settings.latestName = selectedRegion.latestName
        settings.domainToUse = selectedRegion.domainToUse
        settings.genericNewsURLPart = selectedRegion.genericNewsURLPart
        #if DEBUG
            print ("selected region = \(settings.region)")
        #endif

        defaults.setObject(settings.region, forKey: "region")
        defaults.setObject(settings.useToRetrieveLists, forKey: "useToRetrieveLists")
        defaults.setObject(settings.mostPopularName, forKey: "mostPopularName")
        defaults.setObject(settings.latestName, forKey: "latestName")
        defaults.setObject(settings.domainToUse, forKey: "domainToUse")
        defaults.setObject(settings.genericNewsURLPart, forKey: "genericNewsURLPart")
        
//        #if DEBUG
//            print ("Settings = \(settings.description)")
//        #endif
        
        NSNotificationCenter.defaultCenter().postNotificationName("regionChangedNotification", object: nil, userInfo: ["region": selectedRegion]) //userInfo parameter has to be of type [NSObject : AnyObject]?

        self.view.endEditing(true)
    }
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // The list of currently supported by the server. 
    func listLanguages(){
        #if DEBUG
            print("settingsView, listLanguages: self.settings.languages=\(self.settings.languages)")
        #endif
        
        if !self.settings.languages.isEmpty {
            #if DEBUG
                print("settingsView, listLanguages: getting languages from settings")
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
            print("settingsView, listLanguages: getting languages from API")
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
//        self.countryPicker.reloadAllComponents()

        var defaultRowIndex = 0
        for (index, element) in self.languages.enumerate() {
            let lang = element as Language
            if (lang.country == self.settings.region) {
                defaultRowIndex = index
            }
        }
        #if DEBUG
            print("settingsView, setSelectedRegion: region=\(self.settings.region), defaultRowIndex=\(defaultRowIndex)")
        #endif
//        self.countryPicker.selectRow(defaultRowIndex, inComponent: 0, animated: false)
	    self.regionDetailLabel.text = self.languages[defaultRowIndex].country
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

	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
