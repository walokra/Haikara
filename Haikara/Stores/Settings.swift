//
//  Settings.swift
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
    let includePaid: Bool
	
	let fontName: String
	let useSystemSize: Bool
	let fontSizeBase: CGFloat
}

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
            includePaid: false,
			fontName: "Avenir-Light",
			useSystemSize: true,
			fontSizeBase: 10.0
		)
	
    //MARK: Shared Instance

    static let sharedInstance : Settings = {
        let instance = Settings()
        return instance
    }()
	
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
	
    var region: String

    var languagesUpdated = Date()
    var languages = [Language]()
    
    var categoriesUpdatedByLang = Dictionary<String, Date>()
    var categoriesByLang = Dictionary<String, Array<Category>>()
    var categories = [Category]()
    var categoriesFavorited = Dictionary<String, Array<Int>>()
    var categoriesHidden = Dictionary<String, Array<Int>>()
	
	var newsSourcesUpdatedByLang = Dictionary<String, Date>()
	var newsSourcesByLang = Dictionary<String, Array<NewsSources>>()
	var newsSourcesFiltered = Dictionary<String, Array<Int>>()
	var newsSources = [NewsSources]()
	
	var todayCategoryByLang = Dictionary<String, Category>()
	
	var optOutAnalytics: Bool
	
    var includePaid: Bool

	var fontName: String
	var useSystemSize: Bool
	var fontSizeBase: CGFloat
	var fontSizeXLarge: UIFont
	var fontSizeLarge: UIFont
	var fontSizeMedium: UIFont
	var fontSizeSmall: UIFont
	
	let defaults: UserDefaults = UserDefaults.init(suiteName: "group.com.ruleoftech.highkara")!
	
	// MARK: Init
	
	init() {
        #if DEBUG
            print(#function)
        #endif
        
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        self.APIKEY = ""

        self.appID = "Highkara, \(version)-\(build) (iOS)"
        
        self.highFiEndpoint = "json-private"
        self.highFiActCategory = "listCategories"
        self.highFiActUsedLanguage = "usedLanguage"

		NSKeyedUnarchiver.setClass(Category.self, forClassName: "highkara.Category")
		NSKeyedUnarchiver.setClass(Language.self, forClassName: "highkara.Language")
		NSKeyedUnarchiver.setClass(NewsSources.self, forClassName: "highkara.NewsSources")

        if let useToRetrieveLists: String = defaults.object(forKey: "useToRetrieveLists") as? String {
            self.useToRetrieveLists = useToRetrieveLists
        } else {
            self.useToRetrieveLists = defaultValues.useToRetrieveLists
        }
        if let mostPopularName: String = defaults.object(forKey: "mostPopularName") as? String {
            self.mostPopularName = mostPopularName
        } else {
            self.mostPopularName = defaultValues.mostPopularName
        }
        if let latestName: String = defaults.object(forKey: "latestName") as? String {
            self.latestName = latestName
        } else {
            self.latestName = defaultValues.latestName
        }
        if let domainToUse: String = defaults.object(forKey: "domainToUse") as? String {
            self.domainToUse = domainToUse
        } else {
            self.domainToUse = defaultValues.domainToUse
        }
        if let genericNewsURLPart: String = defaults.object(forKey: "genericNewsURLPart") as? String {
            self.genericNewsURLPart = genericNewsURLPart
        } else {
            self.genericNewsURLPart = defaultValues.genericNewsURLPart
        }
		
		self.deviceID = UUID().uuidString
				
        // SettingsView
        if let showDesc: Bool = defaults.object(forKey: "showDesc") as? Bool {
            self.showDesc = showDesc
        } else {
            self.showDesc = defaultValues.showDesc
        }
        
        if let useMobileUrl: Bool = defaults.object(forKey: "useMobileUrl") as? Bool {
            self.useMobileUrl = useMobileUrl
        } else {
            self.useMobileUrl = defaultValues.useMobileUrl
        }
        
        if let useReaderView: Bool = defaults.object(forKey: "useReaderView") as? Bool {
            self.useReaderView = useReaderView
        } else {
            self.useReaderView = defaultValues.useReaderView
        }

        if let useDarkTheme: Bool = defaults.object(forKey: "useDarkTheme") as? Bool {
            self.useDarkTheme = useDarkTheme
        } else {
            self.useDarkTheme = defaultValues.useDarkTheme
        }
		
		if let showNewsPicture: Bool = defaults.object(forKey: "showNewsPicture") as? Bool {
            self.showNewsPicture = showNewsPicture
        } else {
            self.showNewsPicture = defaultValues.showNewsPicture
        }
		
		if let useChrome: Bool = defaults.object(forKey: "useChrome") as? Bool {
            self.useChrome = useChrome
        } else {
            self.useChrome = defaultValues.useChrome
        }
		if let createNewTab: Bool = defaults.object(forKey: "createNewTab") as? Bool {
            self.createNewTab = createNewTab
        } else {
            self.createNewTab = defaultValues.createNewTab
        }

        if let region: String = defaults.object(forKey: "region") as? String {
            self.region = region
        } else {
            self.region = defaultValues.region
        }
        self.preferredLanguage = Locale.preferredLanguages[0] 

        do {
            // Get array of languages from storage
            if let unarchivedLanguages = defaults.data(forKey: "languages") {
                self.languages = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, Language.self, NSString.self], from: unarchivedLanguages) as! [Language]
            }

            // Get Dictionary of categories from storage
            if let categoriesByLangData = defaults.data(forKey: "categoriesByLang"),
               let unarchivedCategoriesByLang = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, Category.self, NSString.self], from: categoriesByLangData) as? Dictionary<String, Array<Category>> {
                self.categoriesByLang = unarchivedCategoriesByLang
                
                if let categories: [Category] = categoriesByLang[self.region] {
                    self.categories = categories
                }
            }
            
            if let categoriesFavorited: Dictionary<String, Array<Int>> = defaults.object(forKey: "categoriesFavorited") as? Dictionary<String, Array<Int>> {
                self.categoriesFavorited = categoriesFavorited
            }
            
            if let categoriesHidden: Dictionary<String, Array<Int>> = defaults.object(forKey: "categoriesHidden") as? Dictionary<String, Array<Int>> {
                self.categoriesHidden = categoriesHidden
            }
            
            // Get dates when data was updated last time from API
            if let languagesUpdated: Date = defaults.object(forKey: "languagesUpdated") as? Date {
                self.languagesUpdated = languagesUpdated
            }
            if let categoriesUpdatedByLang: Dictionary<String, Date> = defaults.object(forKey: "categoriesUpdatedByLang") as? Dictionary<String, Date> {
                self.categoriesUpdatedByLang = categoriesUpdatedByLang
            }
            if let newsSourcesUpdatedByLang: Dictionary<String, Date> = defaults.object(forKey: "newsSourcesUpdatedByLang") as? Dictionary<String, Date> {
                self.newsSourcesUpdatedByLang = newsSourcesUpdatedByLang
            }
            
            if let todayCategoryByLangData = defaults.data(forKey: "todayCategoryByLang"),
               let unarchivedtodayCategoryByLang = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, Category.self, NSString.self], from: todayCategoryByLangData) as? Dictionary<String, Category> {
                self.todayCategoryByLang = unarchivedtodayCategoryByLang
            }

            // Get Dictionary of news sources from storage
            if let newsSourcesByLangData = defaults.data(forKey: "newsSourcesByLang"),
               let unarchivedNewsSourcesByLang = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, NewsSources.self, NSString.self], from: newsSourcesByLangData) as? Dictionary<String, Array<NewsSources>> {
                self.newsSourcesByLang = unarchivedNewsSourcesByLang
                if let newsSources: [NewsSources] = newsSourcesByLang[self.region] {
                    self.newsSources = newsSources
                }
            }
        }
        catch {
            #if DEBUG
                print("error: \(error)")
            #endif
        }
		
        if let newsSourcesFiltered: Dictionary<String, Array<Int>> = defaults.object(forKey: "newsSourcesFiltered") as? Dictionary<String, Array<Int>> {
            self.newsSourcesFiltered = newsSourcesFiltered
        }
		
		if let optOutAnalytics: Bool = defaults.object(forKey: "optOutAnalytics") as? Bool {
            self.optOutAnalytics = optOutAnalytics
        } else {
            self.optOutAnalytics = defaultValues.optOutAnalytics
        }
		
        if let includePaid: Bool = defaults.object(forKey: "includePaid") as? Bool {
            self.includePaid = includePaid
        } else {
            self.includePaid = defaultValues.includePaid
        }

		if let fontName: String = defaults.object(forKey: "fontName") as? String {
            self.fontName = fontName
        } else {
            self.fontName = defaultValues.fontName
        }
		if let useSystemSize: Bool = defaults.object(forKey: "useSystemSize") as? Bool {
            self.useSystemSize = useSystemSize
        } else {
            self.useSystemSize = defaultValues.useSystemSize
        }
		
		if let fontSizeBase: CGFloat = defaults.object(forKey: "fontSizeBase") as? CGFloat {
            self.fontSizeBase = fontSizeBase
        } else {
            self.fontSizeBase = defaultValues.fontSizeBase
        }

		if self.useSystemSize {
			self.fontSizeXLarge = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
			self.fontSizeLarge = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.subheadline)
			self.fontSizeSmall = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1)
			self.fontSizeMedium = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)
		} else {
			self.fontSizeXLarge = UIFont.systemFont(ofSize: self.fontSizeBase + 6.0)
			self.fontSizeLarge = UIFont.systemFont(ofSize: self.fontSizeBase + 5.0)
			self.fontSizeSmall = UIFont.systemFont(ofSize: self.fontSizeBase + 2.0)
			self.fontSizeMedium = UIFont.systemFont(ofSize: self.fontSizeBase + 3.0)
		}

		self.defaults.synchronize()

        #if DEBUG
            print("\(self.description)")
        #endif
    }
    
    var description: String {
		return "Settings: APIKEY=\(self.APIKEY), deviceID=\(self.deviceID), appID=\(self.appID), preferredLanguage=\(self.preferredLanguage), highFiEndpoint=\(self.highFiEndpoint), highFiActCategory=\(self.highFiActCategory), highFiActUsedLanguage=\(self.highFiActUsedLanguage), useToRetrieveLists=\(self.useToRetrieveLists), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), domainToUse=\(self.domainToUse), genericNewsURLPart=\(self.genericNewsURLPart), showDesc=\(self.showDesc), useMobileUrl=\(self.useMobileUrl), useReaderView=\(self.useReaderView), useDarkTheme=\(self.useDarkTheme), showNewsPicture=\(self.showNewsPicture), useChrome=\(self.useChrome), region=\(self.region), todayCategoryByLang=\(String(describing: todayCategoryByLang[self.region])), optOutAnalytics=\(self.optOutAnalytics), includePaid=\(self.includePaid), fontName=\(self.fontName), useSystemSize=\(self.useSystemSize), fontSizeBase=\(self.fontSizeBase)"
    }
	
	func resetToDefaults() {
        self.useToRetrieveLists = defaultValues.useToRetrieveLists
        defaults.set(self.useToRetrieveLists, forKey: "useToRetrieveLists")
        
        self.mostPopularName = defaultValues.mostPopularName
        defaults.set(self.mostPopularName, forKey: "mostPopularName")

        self.latestName = defaultValues.latestName
        defaults.set(self.latestName, forKey: "latestName")

        self.domainToUse = defaultValues.domainToUse
        defaults.set(self.domainToUse, forKey: "domainToUse")
        
        self.genericNewsURLPart = defaultValues.genericNewsURLPart
        defaults.set(self.genericNewsURLPart, forKey: "genericNewsURLPart")
        
        defaults.set(UUID().uuidString, forKey: "deviceID")
        self.deviceID = defaults.string(forKey: "deviceID")!
        
        self.showDesc = defaultValues.showDesc
        defaults.set(self.showDesc, forKey: "showDesc")
        
        self.useMobileUrl = defaultValues.useMobileUrl
        defaults.set(self.useMobileUrl, forKey: "useMobileUrl")
        
        self.useReaderView = defaultValues.useReaderView
        defaults.set(self.useReaderView, forKey: "useReaderView")

        self.useDarkTheme = defaultValues.useDarkTheme
        defaults.set(self.useDarkTheme, forKey: "useDarkTheme")
		
		self.showNewsPicture = defaultValues.showNewsPicture
        defaults.set(self.showNewsPicture, forKey: "showNewsPicture")

		self.useChrome = defaultValues.useChrome
        defaults.set(self.useChrome, forKey: "useChrome")
		self.createNewTab = defaultValues.createNewTab
        defaults.set(self.createNewTab, forKey: "createNewTab")

        self.region = defaultValues.region
        defaults.set(self.region, forKey: "region")
        
        self.categoriesFavorited = Dictionary<String, Array<Int>>()
        defaults.set(self.categoriesFavorited, forKey: "categoriesFavorited")
        
        self.categoriesHidden = Dictionary<String, Array<Int>>()        
        defaults.set(self.categoriesHidden, forKey: "categoriesHidden")
        
        do {
            self.categoriesByLang = Dictionary<String, Array<Category>>()
            defaults.set(self.categoriesByLang, forKey: "categoriesByLang")
            let archivedCategoriesByLang = try NSKeyedArchiver.archivedData(withRootObject: self.categoriesByLang as Dictionary<String, Array<Category>>, requiringSecureCoding: false)
            defaults.set(archivedCategoriesByLang, forKey: "categoriesByLang")
            
            self.categories = [Category]()

            self.todayCategoryByLang = Dictionary<String, Category>()
            defaults.set(self.todayCategoryByLang, forKey: "todayCategoryByLang")
            let archivedTodayCategoryByLang = try NSKeyedArchiver.archivedData(withRootObject:self.todayCategoryByLang as Dictionary<String, Category>, requiringSecureCoding: false)
            defaults.set(archivedTodayCategoryByLang, forKey: "todayCategoryByLang")

            self.languages = [Language]()
            let archivedLanguages = try NSKeyedArchiver.archivedData(withRootObject:self.languages as [Language], requiringSecureCoding:false)
            defaults.set(archivedLanguages, forKey: "languages")
            
            self.newsSourcesFiltered = Dictionary<String, Array<Int>>()
            defaults.set(self.newsSourcesFiltered, forKey: "newsSourcesFiltered")
            
            self.newsSourcesByLang = Dictionary<String, Array<NewsSources>>()
            defaults.set(self.newsSourcesByLang, forKey: "newsSourcesByLang")
            
            let archivedNewsSourcesByLang = try NSKeyedArchiver.archivedData(withRootObject: self.newsSourcesByLang  as Dictionary<String, Array<NewsSources>>, requiringSecureCoding: false)
            defaults.set(archivedNewsSourcesByLang, forKey: "newsSourcesByLang")
        }
        catch {
            #if DEBUG
                print("error: \(error)")
            #endif
        }

        self.newsSources = [NewsSources]()
		
		self.optOutAnalytics = defaultValues.optOutAnalytics
        defaults.set(self.optOutAnalytics, forKey: "optOutAnalytics")

        self.includePaid = defaultValues.includePaid
        defaults.set(self.includePaid, forKey: "includePaid")
		
		self.fontName = defaultValues.fontName
		defaults.set(self.fontName, forKey: "fontName")
		self.useSystemSize = defaultValues.useSystemSize
		defaults.set(self.useSystemSize, forKey: "useSystemSize")
		self.fontSizeBase = defaultValues.fontSizeBase
		defaults.set(self.fontSizeBase, forKey: "fontSizeBase")
		
        #if DEBUG
            print("Settings resetted to defaults: \(self.description)")
        #endif
        
        defaults.synchronize()
    }

	func removeSource(_ sourceID: Int) -> Bool {
		var removed: Bool = false
        if var sourceFilteredForLang = self.newsSourcesFiltered[self.region] {
            #if DEBUG
                print("sourceFilteredForLang=\(sourceFilteredForLang)")
            #endif
            
            if let index = sourceFilteredForLang.firstIndex(of: sourceID) {
				#if DEBUG
	                print("Removing item at index \(index)")
				#endif
                sourceFilteredForLang.remove(at: index)
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
            print("newsSourcesFiltered[\(self.region)]=\(String(describing: self.newsSourcesFiltered[self.region]))")
        #endif
		
		return removed
	}

}

