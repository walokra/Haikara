//
//  NewsDetailsInterfaceController.swift
//  highkara
//
//  Created by Marko Wallin on 30/05/2017.
//  Copyright © 2017 Rule of tech. All rights reserved.
//

import WatchKit
import WatchConnectivity

import Foundation

class NewsDetailsInterfaceController: WKInterfaceController {
	
	@IBOutlet var descLabel: WKInterfaceLabel!
	@IBOutlet var publishedLabel: WKInterfaceLabel!
	@IBOutlet var readEntryButton: WKInterfaceButton!
	
	@IBAction func readEntryAction() {
		#if DEBUG
			print("readEntryAction")
		#endif
	}
	
	let calendar = Calendar.autoupdatingCurrent
	let dateFormatter = DateFormatter()
	let publishedFormatter = DateFormatter()
	let publishedTimeFormatter = DateFormatter()
	
  	var entry: Entry? {
    	didSet {
      		if let entry = entry {
	        	descLabel.setText(entry.shortDescription)

				// If published date is over one day, show date, otherwise time
				if getMinutesFromPublished(entry.publishedDateJS) >= 1440 {
					publishedLabel.setText(formatDate(entry.publishedDateJS))
				} else {
					publishedLabel.setText(formatTime(entry.publishedDateJS))
				}
      		}
    	}
  	}
	
  	// MARK: - Helpers
	
	func formatTime(_ dateString: String) -> String {
		let date = dateFormatter.date(from: dateString)
		return publishedTimeFormatter.string(from: date!)
	}
	func formatDate(_ dateString: String) -> String {
		let date = dateFormatter.date(from: dateString)
		return publishedFormatter.string(from: date!)
	}
	
  	override func awake(withContext context: Any?) {
    	super.awake(withContext: context)
		
		var localTimeZone: String { return NSTimeZone.local.abbreviation() ?? "" }

		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
		publishedFormatter.timeZone = TimeZone(abbreviation: localTimeZone)
		publishedFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
		publishedTimeFormatter.timeZone = TimeZone(abbreviation: localTimeZone)
		publishedTimeFormatter.dateFormat = "HH:mm"
		
    	if let entry = context as? Entry { self.entry = entry }
  	}
	
	func getMinutesFromPublished(_ item: String) -> Int {
	if let startDate = dateFormatter.date(from: item) {
			let components = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: startDate, to: Date(), options: [])
			let days = components.day!
			let hours = components.hour!
			let minutes = components.minute!
			
			if days == 0 {
				if hours == 0 {
					if minutes < 0 { return 0 }
					else if minutes < 5 { return 5 }
					else if minutes < 15 { return 15 }
					else if minutes < 30 { return 30 }
					else if minutes < 45 { return 45 }
					else if minutes < 60 { return 60 }
				} else {
					if hours == 1 {
						return 60 * (hours + 1)
					} else {
						return 60 * hours
					}
				}
			} else {
				if days == 1 {
					return 1440
				} else {
					return 1440 * days
				}
			}
		}
		
		return 99999
	}
  
}
