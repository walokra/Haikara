//
//  WatchInterfaceController.swift
//  Watch Extension
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

import WatchKit
import Foundation

class NewsInterfaceController: WKInterfaceController {

	@IBOutlet var newsTable: WKInterfaceTable!
	
	var entries = [Entry]()
	
	override func awake(withContext: Any?) {
		super.awake(withContext: withContext)
		getNews(1)
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
