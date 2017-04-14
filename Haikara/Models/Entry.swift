//
//  Entry.swift
//  highkara
//
//  Created by Marko Wallin on 4.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

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
//  "highlightType": "popular"
//},

class Entry: NSObject {
    let title: String
    let link: String
    let clickTrackingLink: String
    let author: String
    let publishedDateJS: String
    let picture: String?
    let originalPicture: String?
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
	let highlightType: String
    var timeSince: String
	var orderNro: Int

    init(title: String, link: String, clickTrackingLink: String, author: String, publishedDateJS: String, picture: String?, originalPicture: String?, shortDescription: String?, originalURL: String, mobileLink: String?, originalMobileUrl: String?, shareURL: String, mobileShareURL: String?, articleID: Int, sectionID: Int, sourceID: Int, highlight: Bool, highlightType: String, timeSince: String, orderNro: Int) {
            self.title = title
            self.link = link
            self.clickTrackingLink = clickTrackingLink
            self.author = author
            self.publishedDateJS = publishedDateJS
			self.picture = picture
			self.originalPicture = originalPicture
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
			self.highlightType = highlightType
            self.timeSince = timeSince
			self.orderNro = orderNro
    }

//    override var description: String {
//        return "Entry: title=\(self.title), link=\(self.link), clickTrackingLink=\(self.clickTrackingLink), author=\(self.author), published=\(self.publishedDateJS), picture=\(self.picture), originalPicture=\(self.originalPicture), desc=\(self.shortDescription), originalURL=\(self.originalURL), mobileLink=\(self.mobileLink), originalMobileUrl=\(self.originalMobileUrl), shareURL=\(self.shareURL), mobileShareURL=\(self.mobileShareURL), articleID=\(self.articleID), sectionID=\(self.sectionID), sourceID=\(self.sourceID), highlight=\(self.highlight), highlightType=\(self.highlightType), timeSince=\(self.timeSince), orderNro=\(self.orderNro)"
//    }
}
