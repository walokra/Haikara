//
//  DataModels.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//
//
//  News.swift
//  NewsPages
//
//  Created by Marko Wallin on 21.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

// listLanguages
// http://high.fi/api/?act=listLanguages&APIKEY=123
// { "responseData": { "supportedLanguages": [ { "language": "Finnish", "country": "Finland", "domainToUse": "high.fi", "languageCode": "fi-fi", "mostPopularName": "Suosituimmat", "latestName": "Uusimmat", "useToRetrieveLists": "finnish", "genericNewsURLPart": "uutiset" }, { "language": "English", "country": "United States", "domainToUse": "en.high.fi", "languageCode": "en-us", "mostPopularName": "Most Popular", "latestName": "Latest News", "useToRetrieveLists": "english", "genericNewsURLPart": "news" } ] } }

class Language: NSObject {
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
    }
    
    override var description: String {
        return "Language: language=\(self.language), country=\(self.country), domainToUse=\(self.domainToUse), languageCode=\(self.languageCode), mostPopularName=\(self.mostPopularName), latestName=\(self.latestName), useToRetrieveLists=\(self.useToRetrieveLists), genericNewsURLPart=\(self.genericNewsURLPart)"
    }
}

// listCategories
// http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
// { "responseData": { "categories": [ { "title": "Kotimaa", "sectionID": 95, "depth": 1, "htmlFilename": "kotimaa" }, { "title": "Ulkomaat", "sectionID": 96, "depth": 1, "htmlFilename": "ulkomaat" }, { "title": "Talous", "sectionID": 94, "depth": 1, "htmlFilename": "talous" }, { "title": "Urheilu", "sectionID": 98, "depth": 1, "htmlFilename": "urheilu" } ] } }

class Category: NSObject {
    let title: String
    let sectionID: Int
    let depth: Int
    let htmlFilename: String
    var selected: Bool
    
    init(title: String, sectionID: Int, depth: Int, htmlFilename: String, selected: Bool) {
        self.title = title
        self.sectionID = sectionID
        self.depth = depth
        self.htmlFilename = htmlFilename
        self.selected = selected
    }
    
    override var description: String {
        return "Category: title=\(self.title), sectionID=\(self.sectionID), depth=\(self.depth), htmlFilename=\(self.htmlFilename), selected=\(self.selected)"
    }
}

//{
//	"responseData": {
//		"feed": {
//			"title": "HIGH.FI",
//			"link": "http://fi.high.fi/",
//			"author": "AfterDawn Oy",
//			"description": "News",
//			"type": "json",
//			"entries": [
//{
//	"title": "string",
//	"link": "url",
//	"author": "string",
//	"publishedDateJS": "2015-06-16T22:46:08.000Z",
//	"publishedDate": "June, 16 2015 22:46:08",
//	"originalPicture": "url",
//	"picture": "url",
//	"shortDescription": "",
//	"originalURL": "url",
//	"mobileLink": "",
//	"originalMobileURL": "",
//	"articleID": int,
//	"sectionID": int,
//	"sourceID": int,
//	"highlight": true
//
//},

class Entry: NSObject {
    let title: String
    let link: String
    let clickTrackingLink: String
    let author: String
    let publishedDateJS: String
    //	let picture: String?
    //	let originalPicture: String?
    var shortDescription: String?
    let originalURL: String
    var mobileLink: String?
    let originalMobileUrl: String?
    let shareURL: String
    var mobileShareURL: String?
    let articleID: Int
    var sectionID: Int
    let sourceID: Int
    let highlight: Bool
    var timeSince: String
    
    init(title: String, link: String, clickTrackingLink: String, author: String, publishedDateJS: String,
        shortDescription: String?, originalURL: String, mobileLink: String?, originalMobileUrl: String?, shareURL: String, mobileShareURL: String?, articleID: Int, sectionID: Int, sourceID: Int, highlight: Bool, timeSince: String) {
            self.title = title
            self.link = link
            self.clickTrackingLink = clickTrackingLink
            self.author = author
            self.publishedDateJS = publishedDateJS
            //	let picture: String?
            //	let originalPicture: String?
            self.shortDescription = shortDescription
            self.originalURL = originalURL
            self.mobileLink = mobileLink
            self.originalMobileUrl = originalMobileUrl
            self.shareURL = shareURL
            self.mobileShareURL = mobileShareURL
            self.articleID = articleID
            self.sectionID = sectionID
            self.sourceID = sourceID
            self.highlight = highlight
            self.timeSince = timeSince
    }
    
    override var description: String {
        return "Entry: title=\(self.title), link=\(self.link), clickTrackingLink=\(self.clickTrackingLink), author=\(self.author), published=\(self.publishedDateJS), desc=\(self.shortDescription), originalURL=\(self.originalURL), mobileLink=\(self.mobileLink), originalMobileUrl=\(self.originalMobileUrl), shareURL=\(self.shareURL), mobileShareURL=\(self.mobileShareURL), articleID=\(self.articleID), sectionID=\(self.sectionID), sourceID=\(self.sourceID), highlight=\(self.highlight), timeSince=\(self.timeSince)"
    }
}
