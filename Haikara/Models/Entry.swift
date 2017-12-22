//
//  Entry.swift
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
    var ampURL: String?
    let articleID: Int
    var sectionID: Int
    let sourceID: Int
    let highlight: Bool
	let highlightType: String
    var timeSince: String
	var orderNro: Int

    init(title: String, link: String, clickTrackingLink: String, author: String, publishedDateJS: String, picture: String?, originalPicture: String?, shortDescription: String?, originalURL: String, mobileLink: String?, originalMobileUrl: String?, shareURL: String, mobileShareURL: String?, ampURL: String?, articleID: Int, sectionID: Int, sourceID: Int, highlight: Bool, highlightType: String, timeSince: String, orderNro: Int) {
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
            self.ampURL = ampURL
    }

//    override var description: String {
//        return "Entry: title=\(self.title), link=\(self.link), clickTrackingLink=\(self.clickTrackingLink), author=\(self.author), published=\(self.publishedDateJS), picture=\(self.picture), originalPicture=\(self.originalPicture), desc=\(self.shortDescription), originalURL=\(self.originalURL), mobileLink=\(self.mobileLink), originalMobileUrl=\(self.originalMobileUrl), shareURL=\(self.shareURL), mobileShareURL=\(self.mobileShareURL), ampURL=\(self.ampURL), articleID=\(self.articleID), sectionID=\(self.sectionID), sourceID=\(self.sourceID), highlight=\(self.highlight), highlightType=\(self.highlightType), timeSince=\(self.timeSince), orderNro=\(self.orderNro)"
//    }
}
