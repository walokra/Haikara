//
//  NewsSources.swift
//  highkara
//
//  Created by Marko Wallin on 25.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

// http://high.fi/api/?act=listSources&usedLanguage=Finnish&APIKEY=123
// { "responseData": { "newsSources": [ { "sourceName": "Aamulehti", "sourceID": 316 }, { "sourceName": "Aamuposti", "sourceID": 317 }, { "sourceName": "Aamuset", "sourceID": 318 }, { "sourceName": "AfterDawn", "sourceID": 319 }]}}
class NewsSources: NSObject, NSCoding {
	let sourceName: String
    let sourceID: Int
	var selected: Bool
	
    init(sourceName: String, sourceID: Int, selected: Bool) {
		self.sourceName = sourceName
		self.sourceID = sourceID
		self.selected = selected
		super.init()
    }
	
	required init(coder aDecoder: NSCoder) {
        sourceName = aDecoder.decodeObjectForKey("sourceName") as! String
        sourceID = aDecoder.decodeObjectForKey("sourceID") as! Int
		selected = aDecoder.decodeObjectForKey("selected") as! Bool
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(sourceName, forKey: "sourceName")
        aCoder.encodeObject(sourceID, forKey: "sourceID")
        aCoder.encodeObject(selected, forKey: "selected")
    }
	
    override var description: String {
        return "Language: sourceName=\(self.sourceName), sourceID=\(self.sourceID), selected=\(self.selected)"
    }

}
