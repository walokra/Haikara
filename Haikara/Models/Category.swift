//
//  Category.swift
//  highkara
//
//  Created by Marko Wallin on 4.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
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
        sectionID = decoder.decodeObject(forKey: "sectionID") as! Int
        depth = decoder.decodeObject(forKey: "depth") as! Int
        htmlFilename = decoder.decodeObject(of: NSString.self, forKey: "htmlFilename")! as String
		highlight = decoder.decodeObject(forKey: "highlight") as! Bool
        selected = decoder.decodeObject(forKey: "selected") as! Bool
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
