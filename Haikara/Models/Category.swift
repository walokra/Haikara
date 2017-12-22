//
//  Category.swift
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

// listCategories
// http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
// { "responseData": { "categories": [ { "title": "Kotimaa", "sectionID": 95, "depth": 1, "htmlFilename": "kotimaa" }, { "title": "Ulkomaat", "sectionID": 96, "depth": 1, "htmlFilename": "ulkomaat" }, { "title": "Talous", "sectionID": 94, "depth": 1, "htmlFilename": "talous" }, { "title": "Urheilu", "sectionID": 98, "depth": 1, "htmlFilename": "urheilu" } ] } }
class Category: NSObject, NSCoding {
    let title: String
    let sectionID: Int
    let depth: Int
    let htmlFilename: String
	let highlight: Bool
    var selected: Bool
    
    init(title: String, sectionID: Int, depth: Int, htmlFilename: String, highlight: Bool, selected: Bool) {
        self.title = title
        self.sectionID = sectionID
        self.depth = depth
        self.htmlFilename = htmlFilename
		self.highlight = highlight
        self.selected = selected
        super.init()
    }

    required init(coder decoder: NSCoder) {
        title = decoder.decodeObject(of: NSString.self, forKey: "title")! as String
        sectionID = decoder.decodeObject(forKey: "sectionID") as? Int ?? decoder.decodeInteger(forKey: "sectionID")
        depth = decoder.decodeObject(forKey: "depth") as? Int ?? decoder.decodeInteger(forKey: "depth")
        htmlFilename = decoder.decodeObject(of: NSString.self, forKey: "htmlFilename")! as String
        highlight = decoder.decodeObject(forKey: "highlight") as? Bool ?? decoder.decodeBool(forKey: "highlight")
        selected = decoder.decodeObject(forKey: "selected") as? Bool ?? decoder.decodeBool(forKey: "selected")
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(title, forKey: "title")
        coder.encode(sectionID, forKey: "sectionID")
        coder.encode(depth, forKey: "depth")
        coder.encode(htmlFilename, forKey: "htmlFilename")
		coder.encode(highlight, forKey: "highlight")
        coder.encode(selected, forKey: "selected")
    }
    
//    override var description: String {
//        return "Category: title=\(self.title), sectionID=\(self.sectionID), depth=\(self.depth), htmlFilename=\(self.htmlFilename), highlight=\(self.highlight), selected=\(self.selected)"
//    }
}
