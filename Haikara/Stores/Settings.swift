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
	let region: String
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
			region: "Finland"
		)
    
    func resetToDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()

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
    
    init() {
        #if DEBUG
            print(__FUNCTION__)
        #endif
        
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        self.APIKEY = ""
        
        self.appID = "Highkara, \(version)-\(build) (iOS)"
        
        self.highFiEndpoint = "json-private"
        self.highFiActCategory = "listCategories"
        self.highFiActUsedLanguage = "usedLanguage"
        
        let defaults = NSUserDefaults.standardUserDefaults()

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
        
        if let deviceID = defaults.stringForKey("deviceID") {
            self.deviceID = deviceID
        } else {
            defaults.setObject(NSUUID().UUIDString, forKey: "deviceID")
            self.deviceID = defaults.stringForKey("deviceID")!
            #if DEBUG
                print("Setting new deviceID value: \(self.deviceID)")
            #endif
        }
        
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
		
        // For development
//        self.categoriesByLang = Dictionary<String, Array<Category>>()
//        self.categoriesUpdatedByLang = Dictionary<String, NSDate>()
        
        #if DEBUG
//            println("showDesc: \(self.showDesc)")
//            println("useMobileUrl: \(self.useMobileUrl)")
//            println("region: \(self.region)")
            print("\(self.description)")
        #endif
    
    }
    
    var description: String {
        return "Settings: APIKEY=\(self.APIKEY), deviceID=\(self.deviceID), appID=\(self.appID), preferredLanguage=\(self.preferredLanguage), highFiEndpoint=\(self.highFiEndpoint), highFiActCategory=\(self.highFiActCategory), highFiActUsedLanguage=\(self.highFiActUsedLanguage), useToRetrieveLists=\(self.useToRetrieveLists), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), domainToUse=\(self.domainToUse), genericNewsURLPart=\(self.genericNewsURLPart), showDesc=\(self.showDesc), useMobileUrl=\(self.useMobileUrl), useReaderView=\(self.useReaderView), useDarkTheme=\(self.useDarkTheme), region=\(self.region)"
    }

}

