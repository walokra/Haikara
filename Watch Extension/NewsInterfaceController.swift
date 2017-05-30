//
//  WatchInterfaceController.swift
//  highkara
//
//  Created by Marko Wallin on 14/05/2017.
//  Copyright © 2017 Rule of tech. All rights reserved.
//

import WatchKit
import Foundation

class NewsInterfaceController: WKInterfaceController {

	@IBOutlet var newsTable: WKInterfaceTable!
	
	var entries = [Entry]()
	
	override func awake(withContext: Any?) {
		super.awake(withContext: withContext)
		_ = getNews(1)
	}

	override func table(_: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    	let entry = entries[rowIndex]
//		let controllers = ["NewsEntry", "ReadEntry"]
//		presentController(withNames: controllers, contexts:[entry, entry])
    	presentController(withName: "NewsEntry", context: entry)
	}
	
	func getNews(_ page: Int) -> Void {
           	#if DEBUG
           	    print("WatchInterfaceController, getNews: checking if entries need refreshing")
           	#endif
            
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(page, section: "uutiset",
				completionHandler: { (result) in
//					self.entries = Array(result[0..<5])
					self.entries = Array(result)
					#if DEBUG
						print("entries=\(self.entries.count)")
					#endif
					
					self.newsTable.setNumberOfRows(self.entries.count, withRowType: "NewsRow")
		
					for index in 0..<self.newsTable.numberOfRows {
  						if let controller = self.newsTable.rowController(at: index) as? NewsRowController {
							controller.entry = self.entries[index]
 			 			}
					}
				}
				, failureHandler: {(error) in
					#if DEBUG
						print("entries=\(error)")
					#endif
				}
			)
	}
}
