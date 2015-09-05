//
//  Iconfonts-ionicons.swift
//  highkara
//
//  Created by Marko Wallin on 5.9.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

public extension UIFont{
    class func iconFontOfSize(font: String, fontSize: CGFloat) -> UIFont {
        
        return UIFont(name: font, size: fontSize)!
        
    }
}

public extension String {
    // returns the unicode character representation of the target icon as a String.
    public static func ionIconString(name: String) -> String {
        
        return fetchIconIonIcon(name)
        
    }
}

public extension NSMutableAttributedString {
    // returns an AttributedString containing the target icon and any “suffix” text both at their specified target size.
    public static func ionIconAttributedString(name: String, suffix: String?, iconSize: CGFloat, suffixSize: CGFloat?) -> NSMutableAttributedString {
        
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
        var iconAttributed = NSMutableAttributedString(string: iconString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: suffixFontSize)!])
        
        // Role font awesome over the icon and size according to parameter
        iconAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("ionicon", fontSize: iconSize), range: NSRange(location: 0,length: 1))
        
        return iconAttributed
        
    }
}


func fetchIconIonIcon(name: String) -> String {
    
    // default showing question mark, ion-help
    var returnValue = "\u{f143}"
    let start = name[advance(name.startIndex, 8)]
    
    switch start {
    case "g":
        switch name {
        case "ion-ios-gear-outline": returnValue = "\u{f43c}"
        default : returnValue =  "\u{f143}"
        }
    default:
        returnValue =  "\u{f143}"
    }
    
    return returnValue
}
