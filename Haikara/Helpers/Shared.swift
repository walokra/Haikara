//
//  Shared.swift
//  highkara
//
//  Created by Marko Wallin on 27.10.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool {
        return self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
    }

}

class Shared: NSObject {

	static func hideWhiteSpaceBeforeCell(tableView: UITableView, cell: UITableViewCell) {
		// Cell separator from left side, make it disappear
		if (tableView.respondsToSelector(Selector("separatorInset"))) {
			tableView.separatorInset = UIEdgeInsetsZero
		}
		if (tableView.respondsToSelector(Selector("layoutMargins"))) {
			tableView.layoutMargins = UIEdgeInsetsZero
	    }

		cell.separatorInset = UIEdgeInsetsMake(0, 0, cell.frame.size.width, 0)
		if (cell.respondsToSelector(Selector("preservesSuperviewLayoutMargins"))){
			cell.layoutMargins = UIEdgeInsetsZero
			cell.preservesSuperviewLayoutMargins = false
		}
	}

}
