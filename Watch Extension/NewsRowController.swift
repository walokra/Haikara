//
//  NewsRowController.swift
//  highkara
//
//  Created by Marko Wallin on 14/05/2017.
//  Copyright © 2017 Rule of tech. All rights reserved.
//

import WatchKit

class NewsRowController: NSObject {

	@IBOutlet var newsTitle: WKInterfaceLabel!
//	@IBOutlet var newsDescription: WKInterfaceLabel!
	@IBOutlet var authorLabel: WKInterfaceLabel!

	var entry: Entry? {
	    didSet {
			if let entry = entry {
        		newsTitle.setText(entry.title)
//        		newsDescription.setText(entry.shortDescription)
				authorLabel.setText(entry.author)
			}
    	}
	}

}
