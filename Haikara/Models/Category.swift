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

    required init(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(of: NSString.self, forKey: "title")! as String
        sectionID = aDecoder.decodeInteger(forKey: "sectionID") 
        depth = aDecoder.decodeInteger(forKey: "depth")
        htmlFilename = aDecoder.decodeObject(of: NSString.self, forKey: "htmlFilename")! as String
		highlight = aDecoder.decodeBool(forKey: "highlight")
        selected = aDecoder.decodeBool(forKey: "selected")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(sectionID, forKey: "sectionID")
        aCoder.encode(depth, forKey: "depth")
        aCoder.encode(htmlFilename, forKey: "htmlFilename")
		aCoder.encode(highlight, forKey: "highlight")
        aCoder.encode(selected, forKey: "selected")
    }
    
//    override var description: String {
//        return "Category: title=\(self.title), sectionID=\(self.sectionID), depth=\(self.depth), htmlFilename=\(self.htmlFilename), highlight=\(self.highlight), selected=\(self.selected)"
//    }
}
