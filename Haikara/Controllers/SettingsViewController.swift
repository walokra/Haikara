//
//  SettingsViewController.swift
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

class SettingsViewController: UITableViewController {

	let viewName = "SettingsView"

    // Mark: Outlets
    
	@IBOutlet weak var aboutLabel: UILabel!
	
    // General
    @IBOutlet weak var widgetCategoryLabel: UILabel!
    @IBOutlet weak var widgetCategoryDetailLabel: UILabel!
    
    @IBOutlet weak var regionLabel: UILabel!
    @IBOutlet weak var regionDetailLabel: UILabel!
    
    @IBOutlet weak var includePaidSwitch: UISwitch!
    @IBOutlet weak var includePaidLabel: UILabel!
    
    // Theme
    @IBOutlet weak var useDarkLabel: UILabel!
	@IBOutlet weak var useDarkThemeSwitch: UISwitch!
	
    // Browser
	@IBOutlet weak var useMobileUrlLabel: UILabel!
	@IBOutlet weak var useMobileUrlSwitch: UISwitch!

	@IBOutlet weak var useReaderLabel: UILabel!
	@IBOutlet weak var useReaderViewSwitch: UISwitch!

	@IBOutlet weak var useChromeLabel: UILabel!
	@IBOutlet weak var useChromeSwitch: UISwitch!
	@IBOutlet weak var useChromeCell: UITableViewCell!
	@IBOutlet weak var useChromeNewTabSwitch: UISwitch!
	@IBOutlet weak var useChromeNewTabLabel: UILabel!

	@IBOutlet weak var useChromeNewTabCell: UITableViewCell!

	// Preview
	@IBOutlet weak var previewImage: UIImageView!
	@IBOutlet weak var previewTitle: UILabel!
	@IBOutlet weak var previewAuthor: UILabel!
	@IBOutlet weak var previewDescription: UILabel!
	@IBOutlet weak var previewCell: UITableViewCell!
	@IBOutlet weak var previewImageWidthConstraint: NSLayoutConstraint!
	
	// Theme
	@IBOutlet weak var showDescLabel: UILabel!
	@IBOutlet weak var showDescSwitch: UISwitch!
	@IBOutlet weak var showNewsPictureLabel: UILabel!
	@IBOutlet weak var showNewsPictureSwitch: UISwitch!
	
	// Text size
	@IBOutlet weak var useSystemSizeLabel: UILabel!
	@IBOutlet weak var useSystemSizeSwitch: UISwitch!
	@IBOutlet weak var selectFontSizeSlider: UISlider!
	@IBOutlet weak var fontsizeSmallLabel: UILabel!
	@IBOutlet weak var fontsizeMediumLabel: UILabel!
	@IBOutlet weak var fontsizeLargeLabel: UILabel!

    @IBOutlet weak var optOutAnalyticsLabel: UILabel!
    @IBOutlet weak var optOutAnalyticsSwitch: UISwitch!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var resetLabel: UILabel!
    
	let cancelText: String = NSLocalizedString("CANCEL_BUTTON", comment: "Text for cancel")
	let resetText: String = NSLocalizedString("RESET_BUTTON", comment: "Text for reset")
	
	let fontsizeSmallAccLabel: String = NSLocalizedString("FONT_SMALL_ACC_LABEL", comment: "Accessibility label for small font label")
	let fontsizeMediumAccLabel: String = NSLocalizedString("FONT_MEDIUM_ACC_LABEL", comment: "Accessibility label for medium font label")
	let fontsizeLargeAccLabel: String = NSLocalizedString("FONT_LARGE_ACC_LABEL", comment: "Accessibility label for large font label")

	@IBAction func resetAction(_ sender: UIButton) {
		let alertController = UIAlertController(title: resetAlertTitle, message: resetAlertMessage, preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: cancelText, style: .default, handler: nil)
		alertController.addAction(cancelAction)

		let destroyAction = UIAlertAction(title: resetText, style: .destructive) { (action) in
			#if DEBUG
            	print ("destroyAction, action=\(action)")
        	#endif
			
			self.settings.resetToDefaults()
        
        	HighFiApi.getCategories(
        	    { (result) in
        	        self.settings.categories = result
					
        	        self.settings.categoriesByLang.updateValue(self.settings.categories, forKey: self.settings.region)
	                let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.settings.categoriesByLang as Dictionary<String, Array<Category>>)
        	        self.defaults!.set(archivedObject, forKey: "categoriesByLang")
					self.defaults!.synchronize()
					
                	// Send notification to inform favorite & hide views to refresh
                	NotificationCenter.default.post(name: .settingsResetedNotification, object: nil, userInfo: nil)
					NotificationCenter.default.post(name: .themeChangedNotification, object: nil)
					
					self.setSettings()

                	return
            	}
            	, failureHandler: {(error)in
	                self.handleError(error, title: self.errorTitle)
    	        }
    	    )
        
        	self.listLanguages()
			
        	self.useMobileUrlSwitch.isOn = self.settings.useMobileUrl
        	self.useReaderViewSwitch.isOn = self.settings.useReaderView
		
			// All done
			let doneController = UIAlertController(title: self.resetMessageTitle, message: self.resetMessage, preferredStyle: .alert)
        	let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        	doneController.addAction(OKAction)
			
			self.present(doneController, animated: true) {}
		}
		alertController.addAction(destroyAction)

		self.present(alertController, animated: true) {

		}
    }

    let settings = Settings.sharedInstance
	var defaults: UserDefaults?

    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    let resetMessageTitle: String = NSLocalizedString("SETTINGS_RESET_TITLE", comment: "")
    let resetMessage: String = NSLocalizedString("SETTINGS_RESET_MESSAGE", comment: "")
	let resetAlertTitle: String = NSLocalizedString("SETTINGS_RESET_ALERT_TITLE", comment: "")
    let resetAlertMessage: String = NSLocalizedString("SETTINGS_RESET_ALERT_MESSAGE", comment: "")

	@IBAction func unwindWithSelectedTodayCategory(_ segue:UIStoryboardSegue) {
//  		if let categoryPickerViewController = segue.sourceViewController as? CategoryPickerViewController,
//    		selectedTodayCategory = categoryPickerViewController.selectedTodayCategory {
//				#if DEBUG
//            		print ("selectedTodayCategory \(selectedTodayCategory)")
//        		#endif
//      		self.selectedTodayCategory = selectedTodayCategory
//  		}
	}

	@IBAction func unwindWithSelectedRegion(_ segue:UIStoryboardSegue) {
//  		if let regionPickerViewController = segue.sourceViewController as? RegionPickerViewController,
//    		selectedLanguage = regionPickerViewController.selectedLanguage {
//      		self.selectedLanguage = selectedLanguage
//  		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SelectDisplaySettings" {
//  			if let displaySettingsViewController = segue.destinationViewController as? DisplaySettingsViewController {
				#if DEBUG
            		print ("prepareForSegue: SelectDisplaySettings")
        		#endif
//  			}
		}
		
		if segue.identifier == "SelectTodayCategory" {
  			if let categoryPickerViewController = segue.destination as? CategoryPickerViewController {
				#if DEBUG
            		print ("prepareForSegue: SelectTodayCategory \(String(describing: selectedTodayCategory))")
        		#endif
				categoryPickerViewController.categories = self.categories
    			categoryPickerViewController.selectedTodayCategory = selectedTodayCategory
  			}
		}
		
		if segue.identifier == "SelectLanguage" {
  			if let regionPickerViewController = segue.destination as? RegionPickerViewController {
				regionPickerViewController.languages = self.languages
    			regionPickerViewController.selectedLanguage = selectedLanguage
  			}
		}
	}

    @IBAction func includePaidAction(_ sender: UISwitch) {
        settings.includePaid = sender.isOn
        defaults!.set(settings.includePaid, forKey: "includePaid")
        defaults!.synchronize()
        #if DEBUG
            print ("includePaid \(settings.includePaid), sender.on=\(sender.isOn)")
        #endif
        
        self.trackEvent("includePaid", category: "ui_Event", action: "includePaid", label: "settings", value: (!sender.isOn) ? 1 : 0)
    }
    
	@IBAction func useMobileUrlAction(_ sender: UISwitch) {
        settings.useMobileUrl = sender.isOn
        defaults!.set(settings.useMobileUrl, forKey: "useMobileUrl")
		defaults!.synchronize()
        #if DEBUG
            print ("useMobileUrl \(settings.useMobileUrl), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("useMobileUrl", category: "ui_Event", action: "useMobileUrl", label: "settings", value: (!sender.isOn) ? 1 : 0)
	}

	@IBAction func useReaderViewAction(_ sender: UISwitch) {
		settings.useReaderView = sender.isOn
        defaults!.set(settings.useReaderView, forKey: "useReaderView")
		defaults!.synchronize()
        #if DEBUG
            print ("useReaderView \(settings.useReaderView), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("useReaderView", category: "ui_Event", action: "useReaderView", label: "settings", value: (sender.isOn) ? 1 : 0)
	}

	@IBAction func useDarkThemeAction(_ sender: UISwitch) {
		settings.useDarkTheme = sender.isOn
        defaults!.set(settings.useDarkTheme, forKey: "useDarkTheme")
		defaults!.synchronize()
        #if DEBUG
            print ("useDarkTheme \(settings.useDarkTheme), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("useDarkTheme", category: "ui_Event", action: "useDarkTheme", label: "settings", value: (sender.isOn) ? 1 : 0)

		NotificationCenter.default.post(name: .themeChangedNotification, object: nil)
	}

	@IBAction func useChromeAction(_ sender: UISwitch) {
		settings.useChrome = sender.isOn
        defaults!.set(settings.useChrome, forKey: "useChrome")
		defaults!.synchronize()
        #if DEBUG
            print ("useChrome \(settings.useChrome), sender.on=\(sender.isOn)")
        #endif
		
		self.tableView.reloadData()
		
		self.trackEvent("useChrome", category: "ui_Event", action: "useChrome", label: "settings", value: (sender.isOn) ? 1 : 0)
	}

	@IBAction func useChromeNewTabAction(_ sender: UISwitch) {
		settings.createNewTab = sender.isOn
        defaults!.set(settings.createNewTab, forKey: "createNewTab")
		defaults!.synchronize()
        #if DEBUG
            print ("createNewTab \(settings.createNewTab), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("createNewTab", category: "ui_Event", action: "createNewTab", label: "settings", value: (sender.isOn) ? 1 : 0)
	}
	
	@IBAction func showDescAction(_ sender: UISwitch) {
		settings.showDesc = sender.isOn
        defaults!.set(settings.showDesc, forKey: "showDesc")
		defaults!.synchronize()
        #if DEBUG
            print ("showDesc \(settings.showDesc), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("showDesc", category: "ui_Event", action: "showDesc", label: "settings", value: (sender.isOn) ? 1 : 0)
		
		renderPreview()
	}

	@IBAction func showNewsPictureAction(_ sender: UISwitch) {
		settings.showNewsPicture = sender.isOn
        defaults!.set(settings.showNewsPicture, forKey: "showNewsPicture")
		defaults!.synchronize()
        #if DEBUG
            print ("showNewsPicture \(settings.showNewsPicture), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("showNewsPicture", category: "ui_Event", action: "showNewsPicture", label: "settings", value: (sender.isOn) ? 1 : 0)
		
		renderPreview()
	}
	
	@IBAction func useSystemSizeAction(_ sender: UISwitch) {
		settings.useSystemSize = sender.isOn
        defaults!.set(settings.useSystemSize, forKey: "useSystemSize")
		defaults!.synchronize()
        #if DEBUG
            print ("useSystemSize \(settings.useSystemSize), sender.on=\(sender.isOn)")
        #endif
		
		self.trackEvent("useSystemSize", category: "ui_Event", action: "useSystemSize", label: "settings", value: (sender.isOn) ? 1 : 0)

		Theme.setFonts()
		
		selectFontSizeSlider.isEnabled = !settings.useSystemSize
		
		NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil, userInfo: nil)
	}
	
	@IBAction func selectBaseFontSizeAction(_ sender: UISlider) {
		settings.fontSizeBase = CGFloat(Int(sender.value))
		selectFontSizeSlider.value = round(selectFontSizeSlider.value)
		
		defaults!.set(settings.fontSizeBase, forKey: "fontSizeBase")
		defaults!.synchronize()
        #if DEBUG
            print ("fontSizeBase \(settings.useSystemSize), sender.value=\(sender.value)")
        #endif
		
		self.trackEvent("selectBaseFontSize", category: "ui_Event", action: "selectBaseFontSize", label: "settings", value: sender.value as NSNumber)

		Theme.setFonts()
		
		NotificationCenter.default.post(name: UIContentSizeCategory.didChangeNotification, object: nil, userInfo: nil)
	}
    
    @IBAction func optOutAnalyticsAction(_ sender: UISwitch) {
        self.trackEvent("optOutAnalytics", category: "ui_Event", action: "optOutAnalytics", label: "settings", value: (sender.isOn) ? 1 : 0)
        
        settings.optOutAnalytics = sender.isOn
        defaults!.set(settings.optOutAnalytics, forKey: "optOutAnalytics")
        defaults!.synchronize()
        #if DEBUG
            print ("optOutAnalyticsAction \(settings.optOutAnalytics), sender.on=\(sender.isOn)")
        #endif
        
        NotificationCenter.default.post(name: .optOutAnalyticsChangedNotification, object: nil, userInfo: nil)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		fontsizeSmallLabel.accessibilityLabel = fontsizeSmallAccLabel
		fontsizeMediumLabel.accessibilityLabel = fontsizeMediumAccLabel
		fontsizeLargeLabel.accessibilityLabel = fontsizeLargeAccLabel
		
		listLanguages()
		self.categories = settings.categories
		setSelectedTodayCategory()
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
		renderPreview()

		setSettings()
		
		if !OpenInChromeController.sharedInstance.isChromeInstalled() {
			useChromeCell.isHidden = true
		}
    }
	
	func setSettings() {
        includePaidSwitch.isOn = settings.includePaid
        useMobileUrlSwitch.isOn = settings.useMobileUrl
        useReaderViewSwitch.isOn = settings.useReaderView
		useDarkThemeSwitch.isOn = settings.useDarkTheme
		useChromeSwitch.isOn = settings.useChrome
		useChromeNewTabSwitch.isOn = settings.createNewTab
		optOutAnalyticsSwitch.isOn = settings.optOutAnalytics
		
		showDescSwitch.isOn = settings.showDesc
		showNewsPictureSwitch.isOn = settings.showNewsPicture
		useSystemSizeSwitch.isOn = settings.useSystemSize
		
		selectFontSizeSlider.value = Float(settings.fontSizeBase)
		selectFontSizeSlider.isEnabled = !settings.useSystemSize
	}
	
	func setObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.setTheme(_:)), name: .themeChangedNotification, object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsViewController.setSelectedRegion(_:)), name: "regionChangedNotification", object: nil)
	NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.setTodayCategories(_:)), name: .categoriesRefreshedNotification, object: nil)
	NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.setTodayCategory(_:)), name: .todayCategoryChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.setContentSize(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
		
	}
	
	func setTheme() {
		#if DEBUG
            print("SettingsViewController, setTheme()")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
        includePaidLabel.textColor = Theme.textColor
		useMobileUrlLabel.textColor = Theme.textColor
		useReaderLabel.textColor = Theme.textColor
		useChromeLabel.textColor = Theme.textColor
		useChromeNewTabLabel.textColor = Theme.textColor

		widgetCategoryLabel.textColor = Theme.textColor
		regionLabel.textColor = Theme.textColor

		optOutAnalyticsLabel.textColor = Theme.textColor

		resetLabel.textColor = Theme.textColor
		resetButton.setTitleColor(Theme.textColor, for: UIControl.State())
		
		aboutLabel.textColor = Theme.textColor

		// Theme
		useDarkLabel.textColor = Theme.textColor
		showDescLabel.textColor = Theme.textColor
		showNewsPictureLabel.textColor = Theme.textColor
		useSystemSizeLabel.textColor = Theme.textColor
		fontsizeSmallLabel.textColor = Theme.textColor
		fontsizeMediumLabel.textColor = Theme.textColor
		fontsizeLargeLabel.textColor = Theme.textColor
		
		renderPreview()
		
		self.tableView.reloadData()
	}

	@objc func setTheme(_ notification: Notification) {
        #if DEBUG
            print("SettingsViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	func setContentSize() {
		tableView.reloadData()
		
        includePaidLabel.font = settings.fontSizeLarge
		useMobileUrlLabel.font = settings.fontSizeLarge
		useReaderLabel.font = settings.fontSizeLarge
		useDarkLabel.font = settings.fontSizeLarge
		useChromeLabel.font = settings.fontSizeLarge
		useChromeNewTabLabel.font = settings.fontSizeLarge
		optOutAnalyticsLabel.font = settings.fontSizeLarge

		widgetCategoryLabel.font = settings.fontSizeLarge
		regionLabel.font = settings.fontSizeLarge
		
		resetLabel.font = settings.fontSizeMedium
		resetButton.titleLabel!.font = settings.fontSizeMedium
		
		aboutLabel.font = settings.fontSizeLarge
		
		showDescLabel.font = settings.fontSizeLarge
		showNewsPictureLabel.font = settings.fontSizeLarge
		useSystemSizeLabel.font = settings.fontSizeLarge
		
		renderPreview()
	}
	
	@objc func setContentSize(_ notification: Notification) {
		#if DEBUG
            print("DetailViewController, Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}
	
	func setSelectedRegion(_ notification: Notification) {
        #if DEBUG
            print("SettingsViewController, Received regionChangedNotification")
        #endif
		setSelectedRegion()
	}
	
	@objc func setTodayCategories(_ notification: Notification) {
        #if DEBUG
            print("SettingsViewController, Received categoriesRefreshedNotification")
        #endif
		setSelectedRegion() //setSelectedTodayCategory()
	}
	
	@objc func setTodayCategory(_ notification: Notification) {
        #if DEBUG
            print("SettingsViewController, Received todayCategoryChangedNotification")
        #endif
		self.selectedTodayCategory = self.settings.todayCategoryByLang[self.settings.region]
	}

	func renderPreview() {
		previewTitle.font = settings.fontSizeLarge
		previewAuthor.font = settings.fontSizeSmall
		previewDescription.font = settings.fontSizeMedium
		
		previewTitle.textColor = Theme.cellTitleColor
		previewAuthor.textColor = Theme.cellAuthorColor
		if (settings.showDesc) {
			previewDescription.isHidden = false
		} else {
			previewDescription.isHidden = true
		}
		previewDescription.textColor = Theme.cellDescriptionColor
		
		if settings.showNewsPicture {
			previewImage.frame = CGRect(x: previewImage.frame.origin.x, y: previewImage.frame.origin.y, width: 100,height: 100)
			previewImageWidthConstraint.constant = 100
//			previewImage.image = UIImage(named:"iTunesArtwork.png")!
		} else {
//			previewImage.image = nil
			previewImage.frame = CGRect.zero
			previewImageWidthConstraint.constant = 0
		}

		previewCell.setNeedsLayout()
    	previewCell.layoutIfNeeded()
		
		self.tableView.reloadData()
	}
	
    // Mark functions
    
    var categories = [Category]()
    var selectedTodayCategory: Category? {
        didSet {
            widgetCategoryDetailLabel.text? = selectedTodayCategory!.title
        }
    }
    
    func setSelectedTodayCategory() {
        DispatchQueue.main.async {
            if let categories: [Category] = self.settings.categoriesByLang[self.settings.region] {
                #if DEBUG
                    print("SettingsViewController, setting categories for '\(self.settings.region)' from settings")
                #endif
                
                self.categories = categories
            }
            
            var defaultRowIndex = 0
            if (self.settings.todayCategoryByLang[self.settings.region] != nil) {
                for (index, element) in self.categories.enumerated() {
                    let cat = element as Category
                    if (cat.sectionID == self.settings.todayCategoryByLang[self.settings.region]?.sectionID) {
                        defaultRowIndex = index
                    }
                }
            }
            
            #if DEBUG
                print("SettingsViewController, setTodayCategory=\(String(describing: self.settings.todayCategoryByLang[self.settings.region]?.title)), defaultRowIndex=\(defaultRowIndex)")
            #endif
            self.selectedTodayCategory = self.categories[defaultRowIndex]
            
            self.settings.todayCategoryByLang.updateValue(self.selectedTodayCategory!, forKey: self.settings.region)
            let archivedTodayCategoryByLang = NSKeyedArchiver.archivedData(withRootObject: self.settings.todayCategoryByLang as Dictionary<String, Category>)
            self.defaults!.set(archivedTodayCategoryByLang, forKey: "todayCategoryByLang")
            self.defaults!.synchronize()
        }
    }

    // The list of currently supported by the server.
    var languages = [Language]()
    
    func listLanguages(){
        //        #if DEBUG
        //            print("SettingsViewController, listLanguages: self.settings.languages=\(self.settings.languages)")
        //        #endif
        
        if !self.settings.languages.isEmpty {
            #if DEBUG
                print("SettingsViewController, listLanguages: getting languages from settings")
            #endif
            
            let updated: Date = self.settings.languagesUpdated
            let calendar = Calendar.current
            var comps = DateComponents()
            comps.day = 1
            let updatedPlusWeek = (calendar as NSCalendar).date(byAdding: comps, to: updated, options: NSCalendar.Options())
            let today = Date()
            
            #if DEBUG
                print("today=\(today), updated=\(updated), updatedPlusWeek=\(String(describing: updatedPlusWeek))")
            #endif
            
            if updatedPlusWeek!.isLessThanDate(today) {
                getLanguagesFromAPI()
                return
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
                DispatchQueue.main.async {
                    // Clear old entries
                    self.languages = result
                    self.settings.languages = result
                    
//                  #if DEBUG
//                      println("supportedLanguages=\(self.supportedLanguages)")
//                  #endif
                    
                    let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.settings.languages as Array<Language>)
                    
                    self.defaults!.set(archivedObject, forKey: "languages")
                    
                    self.settings.languagesUpdated = Date()
                    self.defaults!.set(self.settings.languagesUpdated, forKey: "languagesUpdated")
                    // Can't use this here, it breaks Interface Builder
//                    #if DEBUG
//                        print("languages update, \(self.settings.languagesUpdated)")
//                    #endif
                    
                    self.defaults!.synchronize()
                    
                    self.setSelectedRegion()
                    
                    return
                }
        }
            , failureHandler: {(error)in
                self.handleError(error, title: self.errorTitle)
        }
        )
    }
    
    var selectedLanguage: Language? {
        didSet {
            regionDetailLabel.text? = selectedLanguage!.country
        }
    }
    func setSelectedRegion() {
        DispatchQueue.main.async {
            var defaultRowIndex = 0
            for (index, element) in self.languages.enumerated() {
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

    // Mark tableView
    
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
   		// Change the color of all cells
   		cell.backgroundColor = Theme.backgroundColor
		cell.textLabel!.textColor = Theme.cellTitleColor
		cell.textLabel!.font = settings.fontSizeLarge
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		cell.selectionStyle = .none
	}
	
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if cell == self.useChromeCell && useChromeCell.isHidden {
            return 0
        }
        if cell == self.useChromeNewTabCell && (useChromeCell.isHidden || !settings.useChrome){
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt:indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        headerView.tintColor = Theme.sectionColor
        headerView.backgroundColor = Theme.sectionColor
        
        var sectionLabel: UILabel
        sectionLabel = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width/2, height: 25))
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

	// stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
