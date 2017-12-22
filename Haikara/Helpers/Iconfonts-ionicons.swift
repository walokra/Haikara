//
//  Iconfonts-ionicons.swift
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

public extension UIFont{
    class func iconFontOfSize(_ font: String, fontSize: CGFloat) -> UIFont {
        
        return UIFont(name: font, size: fontSize)!
        
    }
}

public extension String {
    // returns the unicode character representation of the target icon as a String.
    public static func ionIconString(_ name: String) -> String {
        
        return fetchIconIonIcon(name)
        
    }
}

public extension NSMutableAttributedString {
    // returns an AttributedString containing the target icon and any “suffix” text both at their specified target size.
    public static func ionIconAttributedString(_ name: String, suffix: String?, iconSize: CGFloat, suffixSize: CGFloat?) -> NSMutableAttributedString {
        
        // Initialise some variables
        var iconString = fetchIconIonIcon(name)
        var suffixFontSize = iconSize
        
        // If there is some suffix text - add it to the string
        if let suffix = suffix {
            iconString = iconString + suffix
        }
        
        // If there is a suffix font size - make a note
        if let suffixSize = suffixSize {
            suffixFontSize = suffixSize
        }
        
        // Build the initial string - using the suffix specifics
        let iconAttributed = NSMutableAttributedString(string: iconString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: suffixFontSize)!])
        
        // Role font awesome over the icon and size according to parameter
        iconAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("ionicon", fontSize: iconSize), range: NSRange(location: 0,length: 1))
        
        return iconAttributed
        
    }
}


func fetchIconIonIcon(_ name: String) -> String {
    // default showing question mark, ion-help
    var returnValue = "\u{f143}"
    switch name {
        case "ion-ios-gear-outline": returnValue = "\u{f43c}"
        case "ion-android-share-alt": returnValue = "\u{f3ac}"
        case "ion-ios-star-outline": returnValue = "\u{f4b2}"
        case "ion-ios-star": returnValue = "\u{f4b3}"
		case "ion-ios-clock-outline": returnValue = "\u{f402}"
		case "ion-ios-upload-outline": returnValue = "\u{f4ca}"
		case "ion-ios-minus-outline": returnValue = "\u{f463}"
		case "ion-ios-world-outline": returnValue = "\u{f4d2}"
        default : returnValue =  "\u{f143}"
    }
    
    return returnValue
}
