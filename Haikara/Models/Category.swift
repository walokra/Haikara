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
    
    required init(title: String, sectionID: Int, depth: Int, htmlFilename: String, highlight: Bool, selected: Bool) {
        self.title = title
        self.sectionID = sectionID
        self.depth = depth
        self.htmlFilename = htmlFilename
		self.highlight = highlight
        self.selected = selected
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObjectForKey("title") as! String
        sectionID = aDecoder.decodeObjectForKey("sectionID") as! Int
        depth = aDecoder.decodeObjectForKey("depth") as! Int
        htmlFilename = aDecoder.decodeObjectForKey("htmlFilename") as! String
		highlight = aDecoder.decodeObjectForKey("highlight") as! Bool
        selected = aDecoder.decodeObjectForKey("selected") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(sectionID, forKey: "sectionID")
        aCoder.encodeObject(depth, forKey: "depth")
        aCoder.encodeObject(htmlFilename, forKey: "htmlFilename")
		aCoder.encodeObject(highlight, forKey: "highlight")
        aCoder.encodeObject(selected, forKey: "selected")
    }
    
    override var description: String {
        return "Category: title=\(self.title), sectionID=\(self.sectionID), depth=\(self.depth), htmlFilename=\(self.htmlFilename), highlight=\(self.highlight), selected=\(self.selected)"
    }
}
