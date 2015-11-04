//
//  Language.swift
//  highkara
//
//  Created by Marko Wallin on 4.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

// listLanguages
// http://high.fi/api/?act=listLanguages&APIKEY=123
// { "responseData": { "supportedLanguages": [ { "language": "Finnish", "country": "Finland", "domainToUse": "high.fi", "languageCode": "fi-fi", "mostPopularName": "Suosituimmat", "latestName": "Uusimmat", "useToRetrieveLists": "finnish", "genericNewsURLPart": "uutiset" }, { "language": "English", "country": "United States", "domainToUse": "en.high.fi", "languageCode": "en-us", "mostPopularName": "Most Popular", "latestName": "Latest News", "useToRetrieveLists": "english", "genericNewsURLPart": "news" } ] } }

class Language: NSObject, NSCoding {
    let language: String
    let country: String
    let domainToUse: String
    let languageCode: String
    let mostPopularName: String
    let latestName: String
    let useToRetrieveLists: String
    let genericNewsURLPart: String
    
    init(language: String, country: String, domainToUse: String, languageCode: String,
        mostPopularName: String, latestName: String, useToRetrieveLists: String, genericNewsURLPart: String) {
            self.language = language
            self.country = country
            self.domainToUse = domainToUse
            self.languageCode = languageCode
            self.mostPopularName = mostPopularName
            self.latestName = latestName
            self.useToRetrieveLists = useToRetrieveLists
            self.genericNewsURLPart = genericNewsURLPart
            super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        language = aDecoder.decodeObjectForKey("language") as! String
        country = aDecoder.decodeObjectForKey("country") as! String
        domainToUse = aDecoder.decodeObjectForKey("domainToUse") as! String
        languageCode = aDecoder.decodeObjectForKey("languageCode") as! String
        mostPopularName = aDecoder.decodeObjectForKey("mostPopularName") as! String
        latestName = aDecoder.decodeObjectForKey("latestName") as! String
        useToRetrieveLists = aDecoder.decodeObjectForKey("useToRetrieveLists") as! String
        genericNewsURLPart = aDecoder.decodeObjectForKey("genericNewsURLPart") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(language, forKey: "language")
        aCoder.encodeObject(country, forKey: "country")
        aCoder.encodeObject(domainToUse, forKey: "domainToUse")
        aCoder.encodeObject(languageCode, forKey: "languageCode")
        aCoder.encodeObject(mostPopularName, forKey: "mostPopularName")
        aCoder.encodeObject(latestName, forKey: "latestName")
        aCoder.encodeObject(useToRetrieveLists, forKey: "useToRetrieveLists")
        aCoder.encodeObject(genericNewsURLPart, forKey: "genericNewsURLPart")
    }
    
    override var description: String {
        return "Language: language=\(self.language), country=\(self.country), domainToUse=\(self.domainToUse), languageCode=\(self.languageCode), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), useToRetrieveLists=\(self.useToRetrieveLists), genericNewsURLPart=\(self.genericNewsURLPart)"
    }
}
