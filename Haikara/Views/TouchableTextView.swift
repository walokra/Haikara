//
//  TouchableTextView.swift
//  highkara
//
//  Created by Marko Wallin on 6.2.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

class TouchableTextView : UITextField {
	
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        self.resignFirstResponder()
        return false
    }

    override func shouldChangeTextInRange(range: UITextRange, replacementText text: String) -> Bool {
        self.resignFirstResponder()
        return false
    }
	
	required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}