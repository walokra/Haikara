//
//  Settings.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

struct Defaults {
	// API defaults
	let useToRetrieveLists: String
	let mostPopularName: String
	let latestName: String
	let domainToUse: String
	let genericNewsURLPart: String
	
	// settings
	let showDesc: Bool
	let useMobileUrl: Bool
	let useReaderView: Bool
	let useDarkTheme: Bool
	let showNewsPicture: Bool
	let useChrome: Bool
	let createNewTab: Bool
	let region: String
	let optOutAnalytics: Bool
	
	let fontName: String
	let useSystemSize: Bool
	let fontSizeBase: CGFloat
}

var instance: Settings?
class Settings {
	let defaultValues = Defaults(
			useToRetrieveLists: "finnish",
			mostPopularName: "Suosituimmat",
			latestName: "Uusimmat",
			domainToUse: "fi.high.fi",
			genericNewsURLPart: "uutiset",
			showDesc: false,
			useMobileUrl: true,
			useReaderView: false,
			useDarkTheme: false,
			showNewsPicture: false,
			useChrome: false,
			createNewTab: false,
			region: "Finland",
			optOutAnalytics: false,
			fontName: "Avenir-Light",
			useSystemSize: true,
			fontSizeBase: 10.0
		)
    
    func resetToDefaults() {
        self.useToRetrieveLists = defaultValues.useToRetrieveLists
        defaults.setObject(self.useToRetrieveLists, forKey: "useToRetrieveLists")
        
        self.mostPopularName = defaultValues.mostPopularName
        defaults.setObject(self.mostPopularName, forKey: "mostPopularName")

        self.latestName = defaultValues.latestName
        defaults.setObject(self.latestName, forKey: "latestName")

        self.domainToUse = defaultValues.domainToUse
        defaults.setObject(self.domainToUse, forKey: "domainToUse")
        
        self.genericNewsURLPart = defaultValues.genericNewsURLPart
        defaults.setObject(self.genericNewsURLPart, forKey: "genericNewsURLPart")
        
        defaults.setObject(NSUUID().UUIDString, forKey: "deviceID")
        self.deviceID = defaults.stringForKey("deviceID")!
        
        self.showDesc = defaultValues.showDesc
        defaults.setObject(self.showDesc, forKey: "showDesc")
        
        self.useMobileUrl = defaultValues.useMobileUrl
        defaults.setObject(self.useMobileUrl, forKey: "useMobileUrl")
        
        self.useReaderView = defaultValues.useReaderView
        defaults.setObject(self.useReaderView, forKey: "useReaderView")

        self.useDarkTheme = defaultValues.useDarkTheme
        defaults.setObject(self.useDarkTheme, forKey: "useDarkTheme")
		
		self.showNewsPicture = defaultValues.showNewsPicture
        defaults.setObject(self.showNewsPicture, forKey: "showNewsPicture")

		self.useChrome = defaultValues.useChrome
        defaults.setObject(self.useChrome, forKey: "useChrome")
		self.createNewTab = defaultValues.createNewTab
        defaults.setObject(self.createNewTab, forKey: "createNewTab")

        self.region = defaultValues.region
        defaults.setObject(self.region, forKey: "region")
        
        self.categoriesFavorited = Dictionary<String, Array<Int>>()
        defaults.setObject(self.categoriesFavorited, forKey: "categoriesFavorited")
        
        self.categoriesHidden = Dictionary<String, Array<Int>>()        
        defaults.setObject(self.categoriesHidden, forKey: "categoriesHidden")
        
        self.categoriesByLang = Dictionary<String, Array<Category>>()
        defaults.setObject(self.categoriesByLang, forKey: "categoriesByLang")
        let archivedCategoriesByLang = NSKeyedArchiver.archivedDataWithRootObject(self.categoriesByLang as Dictionary<String, Array<Category>>)
        defaults.setObject(archivedCategoriesByLang, forKey: "categoriesByLang")
        
        self.categories = [Category]()

        self.todayCategoryByLang = Dictionary<String, Category>()
        defaults.setObject(self.todayCategoryByLang, forKey: "todayCategoryByLang")
        let archivedTodayCategoryByLang = NSKeyedArchiver.archivedDataWithRootObject(self.todayCategoryByLang as Dictionary<String, Category>)
        defaults.setObject(archivedTodayCategoryByLang, forKey: "todayCategoryByLang")

        self.languages = [Language]()
        let archivedLanguages = NSKeyedArchiver.archivedDataWithRootObject(self.languages as [Language])
        defaults.setObject(archivedLanguages, forKey: "languages")
		
        self.newsSourcesFiltered = Dictionary<String, Array<Int>>()
        defaults.setObject(self.newsSourcesFiltered, forKey: "newsSourcesFiltered")
        
        self.newsSourcesByLang = Dictionary<String, Array<NewsSources>>()
        defaults.setObject(self.newsSourcesByLang, forKey: "newsSourcesByLang")
        let archivedNewsSourcesByLang = NSKeyedArchiver.archivedDataWithRootObject(self.newsSourcesByLang as Dictionary<String, Array<NewsSources>>)
        defaults.setObject(archivedNewsSourcesByLang, forKey: "newsSourcesByLang")

        self.newsSources = [NewsSources]()
		
		self.optOutAnalytics = defaultValues.optOutAnalytics
        defaults.setObject(self.optOutAnalytics, forKey: "optOutAnalytics")
		
		self.fontName = defaultValues.fontName
		defaults.setObject(self.fontName, forKey: "fontName")
		self.useSystemSize = defaultValues.useSystemSize
		defaults.setObject(self.useSystemSize, forKey: "useSystemSize")
		self.fontSizeBase = defaultValues.fontSizeBase
		defaults.setObject(self.fontSizeBase, forKey: "fontSizeBase")
		
        #if DEBUG
            print("Settings resetted to defaults: \(self.description)")
        #endif
        
        defaults.synchronize()
    }
	
    // Singleton
    class var sharedInstance: Settings {
        struct Static {
            static var instance: Settings?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = Settings()
        }
        
        return Static.instance!
    }
    
    let APIKEY: String
    var deviceID: String
    let appID: String
    
    let preferredLanguage: String
    
    let highFiEndpoint: String
    let highFiActCategory: String
    let highFiActUsedLanguage: String

    var useToRetrieveLists: String // from useToRetrieveLists variable in JSON
    var mostPopularName: String // to be used as heading for "top news" list, retrieved from JSON
    var latestName: String // to be used as heading for "all latest news" list
    var domainToUse: String // to be used to communicate back and forth with the server using the right domain
    var genericNewsURLPart: String
    
    var showDesc: Bool // Showing descriptions for news items or not
    var useMobileUrl: Bool // Prefer mobile optimized URLs
    var useReaderView: Bool // Use Reader View with SFSafariViewController if available
	var useDarkTheme: Bool // Use Dark Theme
	var showNewsPicture: Bool // Show News Picture
	var useChrome: Bool
	var createNewTab: Bool
	
    var region: String // http://high.fi/api/?act=listLanguages

    var languagesUpdated = NSDate()
    var languages = [Language]()
    
    var categoriesUpdatedByLang = Dictionary<String, NSDate>()
    var categoriesByLang = Dictionary<String, Array<Category>>()
    var categories = [Category]()
    var categoriesFavorited = Dictionary<String, Array<Int>>()
    var categoriesHidden = Dictionary<String, Array<Int>>()
	
	var newsSourcesUpdatedByLang = Dictionary<String, NSDate>()
	var newsSourcesByLang = Dictionary<String, Array<NewsSources>>()
	var newsSourcesFiltered = Dictionary<String, Array<Int>>()
	var newsSources = [NewsSources]()
	
	var todayCategoryByLang = Dictionary<String, Category>()
	
	var optOutAnalytics: Bool
	
	var fontName: String
	var useSystemSize: Bool
	var fontSizeBase: CGFloat
	var fontSizeXLarge: UIFont
	var fontSizeLarge: UIFont
	var fontSizeMedium: UIFont
	var fontSizeSmall: UIFont
	
	let defaults: NSUserDefaults = NSUserDefaults.init(suiteName: "VZSFR9BSV5.group.com.ruleoftech.highkara")!
	
    init() {
        #if DEBUG
            print(#function)
        #endif
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        self.APIKEY = ""

        self.appID = "Highkara, \(version)-\(build) (iOS)"
        
        self.highFiEndpoint = "json-private"
        self.highFiActCategory = "listCategories"
        self.highFiActUsedLanguage = "usedLanguage"

//			NSKeyedArchiver.setClassName("Language", forClass: Language.self)
		NSKeyedUnarchiver.setClass(Category.self, forClassName: "highkara.Category")
		NSKeyedUnarchiver.setClass(Language.self, forClassName: "highkara.Language")
		NSKeyedUnarchiver.setClass(NewsSources.self, forClassName: "highkara.NewsSources")
		
        if let useToRetrieveLists: String = defaults.objectForKey("useToRetrieveLists") as? String {
            self.useToRetrieveLists = useToRetrieveLists
        } else {
            self.useToRetrieveLists = defaultValues.useToRetrieveLists
        }
        if let mostPopularName: String = defaults.objectForKey("mostPopularName") as? String {
            self.mostPopularName = mostPopularName
        } else {
            self.mostPopularName = defaultValues.mostPopularName
        }
        if let latestName: String = defaults.objectForKey("latestName") as? String {
            self.latestName = latestName
        } else {
            self.latestName = defaultValues.latestName
        }
        if let domainToUse: String = defaults.objectForKey("domainToUse") as? String {
            self.domainToUse = domainToUse
        } else {
            self.domainToUse = defaultValues.domainToUse
        }
        if let genericNewsURLPart: String = defaults.objectForKey("genericNewsURLPart") as? String {
            self.genericNewsURLPart = genericNewsURLPart
        } else {
            self.genericNewsURLPart = defaultValues.genericNewsURLPart
        }
		
		self.deviceID = NSUUID().UUIDString
		
//        if let deviceID = defaults.stringForKey("deviceID") {
//            self.deviceID = deviceID
//        } else {
//            defaults.setObject(NSUUID().UUIDString, forKey: "deviceID")
//            self.deviceID = defaults.stringForKey("deviceID")!
//            #if DEBUG
//                print("Setting new deviceID value: \(self.deviceID)")
//            #endif
//        }
		
        // SettingsView
        if let showDesc: Bool = defaults.objectForKey("showDesc") as? Bool {
            self.showDesc = showDesc
        } else {
            self.showDesc = defaultValues.showDesc
        }
        
        if let useMobileUrl: Bool = defaults.objectForKey("useMobileUrl") as? Bool {
            self.useMobileUrl = useMobileUrl
        } else {
            self.useMobileUrl = defaultValues.useMobileUrl
        }
        
        if let useReaderView: Bool = defaults.objectForKey("useReaderView") as? Bool {
            self.useReaderView = useReaderView
        } else {
            self.useReaderView = defaultValues.useReaderView
        }

        if let useDarkTheme: Bool = defaults.objectForKey("useDarkTheme") as? Bool {
            self.useDarkTheme = useDarkTheme
        } else {
            self.useDarkTheme = defaultValues.useDarkTheme
        }
		
		if let showNewsPicture: Bool = defaults.objectForKey("showNewsPicture") as? Bool {
            self.showNewsPicture = showNewsPicture
        } else {
            self.showNewsPicture = defaultValues.showNewsPicture
        }
		
		if let useChrome: Bool = defaults.objectForKey("useChrome") as? Bool {
            self.useChrome = useChrome
        } else {
            self.useChrome = defaultValues.useChrome
        }
		if let createNewTab: Bool = defaults.objectForKey("createNewTab") as? Bool {
            self.createNewTab = createNewTab
        } else {
            self.createNewTab = defaultValues.createNewTab
        }

        if let region: String = defaults.objectForKey("region") as? String {
            self.region = region
        } else {
            self.region = defaultValues.region
        }
        self.preferredLanguage = NSLocale.preferredLanguages()[0] 

        // Get array of languages from storage
        if let unarchivedLanguages = defaults.objectForKey("languages") as? NSData {
            self.languages = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedLanguages) as! [Language]
        }

        // Get Dictionary of categories from storage
        if let unarchivedCategoriesByLang = defaults.objectForKey("categoriesByLang") as? NSData {
            self.categoriesByLang = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedCategoriesByLang) as! Dictionary<String, Array<Category>>
            
            if let categories: [Category] = categoriesByLang[self.region] {
                self.categories = categories
            }
        }
        
        if let categoriesFavorited: Dictionary<String, Array<Int>> = defaults.objectForKey("categoriesFavorited") as? Dictionary<String, Array<Int>> {
            self.categoriesFavorited = categoriesFavorited
        }
        
        if let categoriesHidden: Dictionary<String, Array<Int>> = defaults.objectForKey("categoriesHidden") as? Dictionary<String, Array<Int>> {
            self.categoriesHidden = categoriesHidden
        }
        
        // Get dates when data was updated last time from API
        if let languagesUpdated: NSDate = defaults.objectForKey("languagesUpdated") as? NSDate {
            self.languagesUpdated = languagesUpdated
        }
        if let categoriesUpdatedByLang: Dictionary<String, NSDate> = defaults.objectForKey("categoriesUpdatedByLang") as? Dictionary<String, NSDate> {
            self.categoriesUpdatedByLang = categoriesUpdatedByLang
        }
		if let newsSourcesUpdatedByLang: Dictionary<String, NSDate> = defaults.objectForKey("newsSourcesUpdatedByLang") as? Dictionary<String, NSDate> {
            self.newsSourcesUpdatedByLang = newsSourcesUpdatedByLang
        }
		
		// Get Dictionary of today categories from storage
        if let unarchivedtodayCategoryByLang = defaults.objectForKey("todayCategoryByLang") as? NSData {
            self.todayCategoryByLang = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedtodayCategoryByLang) as! Dictionary<String, Category>
		}

        // Get Dictionary of news sources from storage
        if let unarchivedNewsSourcesByLang = defaults.objectForKey("newsSourcesByLang") as? NSData {
            self.newsSourcesByLang = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedNewsSourcesByLang) as! Dictionary<String, Array<NewsSources>>
            
            if let newsSources: [NewsSources] = newsSourcesByLang[self.region] {
                self.newsSources = newsSources
            }
        }
		
        if let newsSourcesFiltered: Dictionary<String, Array<Int>> = defaults.objectForKey("newsSourcesFiltered") as? Dictionary<String, Array<Int>> {
            self.newsSourcesFiltered = newsSourcesFiltered
        }
		
		if let optOutAnalytics: Bool = defaults.objectForKey("optOutAnalytics") as? Bool {
            self.optOutAnalytics = optOutAnalytics
        } else {
            self.optOutAnalytics = defaultValues.optOutAnalytics
        }
		
		if let fontName: String = defaults.objectForKey("fontName") as? String {
            self.fontName = fontName
        } else {
            self.fontName = defaultValues.fontName
        }
		if let useSystemSize: Bool = defaults.objectForKey("useSystemSize") as? Bool {
            self.useSystemSize = useSystemSize
        } else {
            self.useSystemSize = defaultValues.useSystemSize
        }
		
		if let fontSizeBase: CGFloat = defaults.objectForKey("fontSizeBase") as? CGFloat {
            self.fontSizeBase = fontSizeBase
        } else {
            self.fontSizeBase = defaultValues.fontSizeBase
        }

		if self.useSystemSize {
			self.fontSizeXLarge = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
			self.fontSizeLarge = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
			self.fontSizeSmall = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
			self.fontSizeMedium = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
		} else {
			self.fontSizeXLarge = UIFont.systemFontOfSize(self.fontSizeBase + 6.0)
			self.fontSizeLarge = UIFont.systemFontOfSize(self.fontSizeBase + 5.0)
			self.fontSizeSmall = UIFont.systemFontOfSize(self.fontSizeBase + 2.0)
			self.fontSizeMedium = UIFont.systemFontOfSize(self.fontSizeBase + 3.0)
		}

		self.defaults.synchronize()

        // For development
//        self.categoriesByLang = Dictionary<String, Array<Category>>()
//        self.categoriesUpdatedByLang = Dictionary<String, NSDate>()
        
        #if DEBUG
            print("\(self.description)")
        #endif
    }
    
    var description: String {
		return "Settings: APIKEY=\(self.APIKEY), deviceID=\(self.deviceID), appID=\(self.appID), preferredLanguage=\(self.preferredLanguage), highFiEndpoint=\(self.highFiEndpoint), highFiActCategory=\(self.highFiActCategory), highFiActUsedLanguage=\(self.highFiActUsedLanguage), useToRetrieveLists=\(self.useToRetrieveLists), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), domainToUse=\(self.domainToUse), genericNewsURLPart=\(self.genericNewsURLPart), showDesc=\(self.showDesc), useMobileUrl=\(self.useMobileUrl), useReaderView=\(self.useReaderView), useDarkTheme=\(self.useDarkTheme), showNewsPicture=\(self.showNewsPicture), useChrome=\(self.useChrome), region=\(self.region), todayCategoryByLang=\(todayCategoryByLang[self.region]), optOutAnalytics=\(self.optOutAnalytics), fontName=\(self.fontName), useSystemSize=\(self.useSystemSize), fontSizeBase=\(self.fontSizeBase)"
    }
	
	func removeSource(sourceID: Int) -> Bool {
		var removed: Bool = false
        if var sourceFilteredForLang = self.newsSourcesFiltered[self.region] {
            #if DEBUG
                print("sourceFilteredForLang=\(sourceFilteredForLang)")
            #endif
            
            if let index = sourceFilteredForLang.indexOf(sourceID) {
				#if DEBUG
	                print("Removing item at index \(index)")
				#endif
                sourceFilteredForLang.removeAtIndex(index)
                removed = true
            }
            if (!removed) {
				#if DEBUG
					print("Adding item to filtered sources, \(sourceID)")
				#endif
                sourceFilteredForLang.append(sourceID)
            }
            self.newsSourcesFiltered.updateValue(sourceFilteredForLang, forKey: self.region)
        } else {
			#if DEBUG
	            print("Creating new key for language news sources, \(self.region)")
			#endif
            self.newsSourcesFiltered.updateValue([sourceID], forKey: self.region)
        }
        
        #if DEBUG
            print("newsSourcesFiltered[\(self.region)]=\(self.newsSourcesFiltered[self.region])")
        #endif
		
		return removed
	}

}

