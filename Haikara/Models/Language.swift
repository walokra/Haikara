//
//  Language.swift
//  highkara
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
