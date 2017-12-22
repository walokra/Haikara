//
//  Shared.swift
//  highkara
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
		guard let gai = GAI.sharedInstance() else { return }
		if (gai.optOut) {
    	    return
		}
        
        guard let tracker = gai.defaultTracker else { return }
        tracker.set(kGAIScreenName, value: viewName)

        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    func trackEvent(_ event: String, category: String, action: String, label: String, value: NSNumber?) {
        guard let gai = GAI.sharedInstance() else { return }
        if (gai.optOut) {
            return
        }
        
        guard let tracker = gai.defaultTracker else { return }
        tracker.set(kGAIEvent, value: event)
        
        guard let trackDictionary = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value) else { return }
        tracker.send(trackDictionary.build() as [NSObject : AnyObject])
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
