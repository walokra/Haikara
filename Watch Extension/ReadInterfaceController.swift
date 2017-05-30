//
//  ReadInterfaceController.swift
//  highkara
//
//  Created by Marko Wallin on 30/05/2017.
//  Copyright © 2017 Rule of tech. All rights reserved.
//

import WatchKit
import Foundation

class ReadInterfaceController: WKInterfaceController {

	var entry: Entry?
	
	@IBOutlet var readButton: WKInterfaceButton!
	
	override func awake(withContext context: Any?) {
    	super.awake(withContext: context)
    	if let entry = context as? Entry { self.entry = entry }
		
		#if DEBUG
			print("awake, \(String(describing: entry?.link))")
		#endif
	
		updateUserActivity(Settings.sharedUserActivityType, userInfo: [Settings.sharedIdentifierKey : entry?.link as Any], webpageURL: nil)
  	}

}
