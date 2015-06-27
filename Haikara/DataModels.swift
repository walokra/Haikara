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

let APIKEY: String = ""
var highFiBase: String = "http://fi.high.fi"
let highFiEndpoint: String = "json-private"
var highFiAPIBase: String = "http://fi.high.fi/api"
let highFiActCategory: String = "listCategories"
var highFiActUsedLanguage: String = "usedLanguage"
var highFiLanguage: String = "finnish"

// Examples
// categories: http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
// { "responseData": { "categories": [ { "title": "Kotimaa", "sectionID": 95, "depth": 1, "htmlFilename": "kotimaa" }, { "title": "Ulkomaat", "sectionID": 96, "depth": 1, "htmlFilename": "ulkomaat" }, { "title": "Talous", "sectionID": 94, "depth": 1, "htmlFilename": "talous" }, { "title": "Urheilu", "sectionID": 98, "depth": 1, "htmlFilename": "urheilu" } ] } }

class Category: NSObject {
    let title: String
    let sectionID: Int
    let depth: Int
    let htmlFilename: String
    
    init(title: String, sectionID: Int, depth: Int, htmlFilename: String) {
        self.title = title
        self.sectionID = sectionID
        self.depth = depth
        self.htmlFilename = htmlFilename
    }
    
    override var description: String {
        return "Category: title=\(self.title), sectionID=\(self.sectionID), depth=\(self.depth), htmlFilename=\(self.htmlFilename)"
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
    let author: String
    let publishedDateJS: String
    //	let picture: String?
    //	let originalPicture: String?
    var shortDescription: String?
    //	let originalURL: String
    var mobileLink: String?
    //	let originalMobileUrl: String?
    //	let articleID: Int
    var sectionID: Int
    //	let sourceID: Int
    //	let highlight: Bool
    var section: String
    
    init(title: String, link: String, author: String, publishedDateJS: String,
        shortDescription: String?, mobileLink: String?, sectionID: Int, section: String) {
            self.title = title
            self.link = link
            self.author = author
            self.publishedDateJS = publishedDateJS
            //	let picture: String?
            //	let originalPicture: String?
            self.shortDescription = shortDescription
            //	letoriginalURL: String
            self.mobileLink = mobileLink
            //	let originalMobileUrl: String?
            //	let articleID: Int
            self.sectionID = sectionID
            //	let sourceID: Int
            //	let highlight: Bool
            self.section = section
    }
    
    override var description: String {
        return "Entry: title=\(self.title), link=\(self.link), author=\(self.author), published=\(self.publishedDateJS), desc=\(self.shortDescription), mobileLink=\(self.mobileLink), sectionID=\(self.sectionID), section=\(section)"
    }
}
