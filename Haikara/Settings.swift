//
//  Settings.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class Settings: NSObject {
   
    let APIKEY: String = ""
    let deviceID: String = "" // NSUUID().UUIDString
    let appID: String = "Haikara, 0.2.0-1 (iOS)"
    
    let highFiEndpoint: String = "json-private"
    let highFiActCategory: String = "listCategories"
    var highFiActUsedLanguage: String = "usedLanguage"

    var useToRetrieveLists: String = "finnish" // from useToRetrieveLists variable in JSON
    var mostPopularName: String = "Suosituimmat"; // to be used as heading for "top news" list, retrieved from JSON
    var latestName: String = "Uutiset"; // to be used as heading for "all latest news" list
    var domainToUse: String = "fi.high.fi" // to be used to communicate back and forth with the server using the right domain
    var genericNewsURLPart: String = "uutiset"

}

