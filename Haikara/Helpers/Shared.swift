//
//  Shared.swift
//  highkara
//
//  Created by Marko Wallin on 27.10.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

extension Date {
    func isGreaterThanDate(_ dateToCompare : Date) -> Bool {
        return self.compare(dateToCompare) == ComparisonResult.orderedDescending
    }
    
    func isLessThanDate(_ dateToCompare : Date) -> Bool {
        return self.compare(dateToCompare) == ComparisonResult.orderedAscending
    }

}

extension Notification.Name {
    static let themeChangedNotification = Notification.Name("themeChangedNotification")
	static let categoriesRefreshedNotification = Notification.Name("categoriesRefreshedNotification")
	static let todayCategoryChangedNotification = Notification.Name("todayCategoryChangedNotification")
	static let settingsResetedNotification = Notification.Name("settingsResetedNotification")
	static let optOutAnalyticsChangedNotification = Notification.Name("optOutAnalyticsChangedNotification")
	static let handleOpenURL = Notification.Name("handleOpenURL")
	static let selectedCategoriesChangedNotification = Notification.Name("selectedCategoriesChangedNotification")
	static let regionChangedNotification = Notification.Name("regionChangedNotification")
	
}

extension UIViewController {
    func sendScreenView(_ viewName: String) {
		let gai = GAI.sharedInstance()
		if !(gai?.optOut)! {
    	    let tracker = gai?.defaultTracker
    	    tracker?.set(kGAIScreenName, value: viewName)
    	    let builder = GAIDictionaryBuilder.createScreenView()
    	    tracker?.send(builder?.build() as! [AnyHashable: Any])
		}
    }

    func trackEvent(_ event: String, category: String, action: String, label: String, value: NSNumber?) {
		let gai = GAI.sharedInstance()
		if !(gai?.optOut)! {
			let tracker = gai?.defaultTracker
			tracker?.set(kGAIEvent, value: event)
        	let trackDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
        	tracker?.send(trackDictionary?.build() as! [AnyHashable: Any])
		}
    }
	
    func handleError(_ error: String, title: String) {
        #if DEBUG
            print("handleError, error: \(error)")
        #endif
		self.trackEvent("handleError", category: "ui_Event", action: "handleError", label: "error", value: 1)
		
        let alertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true){}
    }
}

class Shared: NSObject {

	static func hideWhiteSpaceBeforeCell(_ tableView: UITableView, cell: UITableViewCell) {
		// Cell separator from left side, make it disappear
		if (tableView.responds(to: #selector(getter: UITableViewCell.separatorInset))) {
			tableView.separatorInset = UIEdgeInsets.zero
		}
		if (tableView.responds(to: #selector(getter: UIView.layoutMargins))) {
			tableView.layoutMargins = UIEdgeInsets.zero
	    }

		cell.separatorInset = UIEdgeInsetsMake(0, 0, cell.frame.size.width, 0)
		if (cell.responds(to: #selector(getter: UIView.preservesSuperviewLayoutMargins))){
			cell.layoutMargins = UIEdgeInsets.zero
			cell.preservesSuperviewLayoutMargins = false
		}
	}
}
