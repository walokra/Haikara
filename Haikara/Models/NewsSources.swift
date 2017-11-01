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
        sourceName = aDecoder.decodeObject(of: NSString.self, forKey: "sourceName")! as String
        sourceID = aDecoder.decodeObject(forKey: "sourceID") as! Int
		selected = aDecoder.decodeObject(forKey: "selected") as! Bool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sourceName, forKey: "sourceName")
        aCoder.encode(sourceID, forKey: "sourceID")
        aCoder.encode(selected, forKey: "selected")
    }
	
//    override var description: String {
//        return "Language: sourceName=\(self.sourceName), sourceID=\(self.sourceID), selected=\(self.selected)"
//    }

}
