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
        language = aDecoder.decodeObject(of: NSString.self, forKey: "language")! as String
        country = aDecoder.decodeObject(of: NSString.self, forKey: "country")! as String
        domainToUse = aDecoder.decodeObject(of: NSString.self, forKey: "domainToUse")! as String
        languageCode = aDecoder.decodeObject(of: NSString.self, forKey: "languageCode")! as String
        mostPopularName = aDecoder.decodeObject(of: NSString.self, forKey: "mostPopularName")! as String
        latestName = aDecoder.decodeObject(of: NSString.self, forKey: "latestName")! as String
        useToRetrieveLists = aDecoder.decodeObject(of: NSString.self, forKey: "useToRetrieveLists")! as String
        genericNewsURLPart = aDecoder.decodeObject(of: NSString.self, forKey: "genericNewsURLPart")! as String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(language, forKey: "language")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(domainToUse, forKey: "domainToUse")
        aCoder.encode(languageCode, forKey: "languageCode")
        aCoder.encode(mostPopularName, forKey: "mostPopularName")
        aCoder.encode(latestName, forKey: "latestName")
        aCoder.encode(useToRetrieveLists, forKey: "useToRetrieveLists")
        aCoder.encode(genericNewsURLPart, forKey: "genericNewsURLPart")
    }
    
//    override var description: String {
//        return "Language: language=\(self.language), country=\(self.country), domainToUse=\(self.domainToUse), languageCode=\(self.languageCode), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), useToRetrieveLists=\(self.useToRetrieveLists), genericNewsURLPart=\(self.genericNewsURLPart)"
//    }
}
