//
//  Settings.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

var instance: Settings?
class Settings {
    
    func resetToDefaults() {
        let defaults = NSUserDefaults.standardUserDefaults()

        self.useToRetrieveLists = "finnish"
        defaults.setObject(self.useToRetrieveLists, forKey: "useToRetrieveLists")
        
        self.mostPopularName = "Suosituimmat"
        defaults.setObject(self.mostPopularName, forKey: "mostPopularName")

        self.latestName = "Uusimmat"
        defaults.setObject(self.latestName, forKey: "latestName")

        self.domainToUse = "fi.high.fi"
        defaults.setObject(self.domainToUse, forKey: "domainToUse")
        
        self.genericNewsURLPart = "uutiset"
        defaults.setObject(self.genericNewsURLPart, forKey: "genericNewsURLPart")
        
        defaults.setObject(NSUUID().UUIDString, forKey: "deviceID")
        self.deviceID = defaults.stringForKey("deviceID")!
        
        self.showDesc = true
        defaults.setObject(self.showDesc, forKey: "showDesc")
        
        self.useMobileUrl = true
        defaults.setObject(self.useMobileUrl, forKey: "useMobileUrl")
        
        self.useReaderView = false
        defaults.setObject(self.useReaderView, forKey: "useReaderView")
        
        self.region = "Finland"
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
    var region: String // http://high.fi/api/?act=listLanguages

    var languagesUpdated = NSDate()
    var languages = [Language]()
    
    var categoriesUpdatedByLang = Dictionary<String, NSDate>()
    var categoriesByLang = Dictionary<String, Array<Category>>()
    var categories = [Category]()
    var categoriesFavorited = Dictionary<String, Array<Int>>()
    var categoriesHidden = Dictionary<String, Array<Int>>()
    
    // Messages
    let errorAPINoData: String = NSLocalizedString("ERROR_API_NO_DATA", comment: "Error text when no data from API.")
    let errorAPIParse: String = NSLocalizedString("ERROR_API_PARSE", comment: "Error text when data serialization fails.")
    
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
            self.useToRetrieveLists = "finnish"
        }
        if let mostPopularName: String = defaults.objectForKey("mostPopularName") as? String {
            self.mostPopularName = mostPopularName
        } else {
            self.mostPopularName = "Suosituimmat"
        }
        if let latestName: String = defaults.objectForKey("latestName") as? String {
            self.latestName = latestName
        } else {
            self.latestName = "Uusimmat"
        }
        if let domainToUse: String = defaults.objectForKey("domainToUse") as? String {
            self.domainToUse = domainToUse
        } else {
            self.domainToUse = "fi.high.fi"
        }
        if let genericNewsURLPart: String = defaults.objectForKey("genericNewsURLPart") as? String {
            self.genericNewsURLPart = genericNewsURLPart
        } else {
            self.genericNewsURLPart = "uutiset"
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
            self.showDesc = true
        }
        
        if let useMobileUrl: Bool = defaults.objectForKey("useMobileUrl") as? Bool {
            self.useMobileUrl = useMobileUrl
        } else {
            self.useMobileUrl = true
        }
        
        if let useReaderView: Bool = defaults.objectForKey("useReaderView") as? Bool {
            self.useReaderView = useReaderView
        } else {
            self.useReaderView = false
        }
        
        if let region: String = defaults.objectForKey("region") as? String {
            self.region = region
        } else {
            self.region = "Finland"
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
        return "Settings: APIKEY=\(self.APIKEY), deviceID=\(self.deviceID), appID=\(self.appID), preferredLanguage=\(self.preferredLanguage), highFiEndpoint=\(self.highFiEndpoint), highFiActCategory=\(self.highFiActCategory), highFiActUsedLanguage=\(self.highFiActUsedLanguage), useToRetrieveLists=\(self.useToRetrieveLists), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), domainToUse=\(self.domainToUse), genericNewsURLPart=\(self.genericNewsURLPart), showDesc=\(self.showDesc), useMobileUrl=\(self.useMobileUrl), useReaderView=\(self.useReaderView), region=\(self.region)"
    }

}

