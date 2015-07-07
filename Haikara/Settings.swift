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
    let deviceID: String
    let appID: String
    
    let highFiEndpoint: String
    let highFiActCategory: String
    let highFiActUsedLanguage: String

    let useToRetrieveLists: String // from useToRetrieveLists variable in JSON
    let mostPopularName: String // to be used as heading for "top news" list, retrieved from JSON
    let latestName: String // to be used as heading for "all latest news" list
    let domainToUse: String // to be used to communicate back and forth with the server using the right domain
    let genericNewsURLPart: String
    
    var showDesc: Bool // Showing descriptions for news items or not
    var useMobileUrl: Bool // Prefer mobile optimized URLs
    var country: String // http://high.fi/api/?act=listLanguages
    
    init() {
        #if DEBUG
            println(__FUNCTION__)
        #endif
        
        self.APIKEY = ""
        self.appID = "Haikara, 0.3.0-1 (iOS)"
            
        self.highFiEndpoint = "json-private"
        self.highFiActCategory = "listCategories"
        self.highFiActUsedLanguage = "usedLanguage"
        self.useToRetrieveLists = "finnish"
        self.mostPopularName = "Suosituimmat"
        self.latestName = "Uutiset"
        self.domainToUse = "fi.high.fi"
        self.genericNewsURLPart = "uutiset"
        
        var defaults = NSUserDefaults.standardUserDefaults()
        if let deviceID = defaults.stringForKey("deviceID") {
            self.deviceID = deviceID
            #if DEBUG
                println("settings.deviceID=\(self.deviceID)")
            #endif
        } else {
            defaults.setObject(NSUUID().UUIDString, forKey: "deviceID")
            self.deviceID = defaults.stringForKey("deviceID")!
            #if DEBUG
                println("Setting new deviceID value: \(self.deviceID)")
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
        
        if let country: String = defaults.objectForKey("country") as? String {
            self.country = country
        } else {
            self.country = "Finland"
        }
        
        #if DEBUG
            println("showDesc: \(self.showDesc)")
            println("useMobileUrl: \(self.useMobileUrl)")
            println("country: \(self.country)")
        #endif
    
    }
    
    var description: String {
        return "Settings"
    }

}

