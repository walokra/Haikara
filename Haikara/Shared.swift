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


}
