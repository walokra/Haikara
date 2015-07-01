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
        if (defaults.objectForKey("deviceID") == nil) {
            defaults.setObject(NSUUID().UUIDString, forKey: "deviceID")
            self.deviceID = defaults.stringForKey("deviceID")!
            #if DEBUG
                println("Setting new deviceID value: \(self.deviceID)")
            #endif
        } else {
            self.deviceID = defaults.stringForKey("deviceID")!
            #if DEBUG
                println("settings.deviceID=\(self.deviceID)")
            #endif
        }
    }
    
    var description: String {
        return "Settings"
    }

}

