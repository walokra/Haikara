//
//  Theme.swift
//  highkara
//
//  Created by Marko Wallin on 23.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

struct Theme {

	enum Theme {
		case Default, Dark
	
		var mainColor: UIColor {
			switch self {
			case .Default:
			  return UIColor.blackColor()
			case .Dark:
			  return UIColor.lightGrayColor()
			}
		}
	}

	static var sectionColor: UIColor = Light.sectionColor
	static var backgroundColor: UIColor = Light.backgroundColor
	static var evenRowColor: UIColor = Light.evenRowColor
	static var oddRowColor: UIColor = Light.oddRowColor
	static var cellTitleColor: UIColor = Light.textColor
	static var cellAuthorColor: UIColor = Light.authorColor
	static var cellDescriptionColor: UIColor = Light.descriptionColor
	static var selectedCellBackground = UIView()
	static var barStyle: UIBarStyle = .Default
	
	static var poweredLabelColor: UIColor = Light.poweredLabelColor
	
	static func loadTheme(){
		if let useDarkTheme: Bool = NSUserDefaults.standardUserDefaults().objectForKey("useDarkTheme")?.boolValue {
			(useDarkTheme) ? themeDark() : themeLight()
		} else {
			themeLight()
		}
    }
	
	// MARK: Light Theme Schemes
	static func themeLight(){
		sectionColor = Light.sectionColor
		backgroundColor = Light.backgroundColor
		
		evenRowColor = Light.evenRowColor
		oddRowColor = Light.oddRowColor
		cellTitleColor = Light.textColor
		cellAuthorColor = Light.authorColor
		cellDescriptionColor = Light.descriptionColor
		selectedCellBackground.backgroundColor = Light.selectedBackgroudColor
		
		poweredLabelColor = Light.poweredLabelColor
		
		let sharedApplication = UIApplication.sharedApplication()
		sharedApplication.delegate?.window??.tintColor = UIColor.blackColor()
		UINavigationBar.appearance().barStyle = .Default
		
		sharedApplication.setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
		
		UITabBar.appearance().barStyle = .Default
	}

	// MARK: Dark Theme Schemes
	static func themeDark(){
		sectionColor = Dark.sectionColor
		backgroundColor = Dark.backgroundColor

		evenRowColor = Dark.evenRowColor
		oddRowColor = Dark.oddRowColor
		cellTitleColor = Dark.textColor
		cellAuthorColor = Dark.authorColor
		cellDescriptionColor = Dark.descriptionColor
		selectedCellBackground.backgroundColor = Dark.selectedBackgroudColor
		
		poweredLabelColor = Dark.poweredLabelColor
		
		let sharedApplication = UIApplication.sharedApplication()
		sharedApplication.delegate?.window??.tintColor = UIColor.lightGrayColor()
		UINavigationBar.appearance().barStyle = .Black
		
		sharedApplication.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)

		UITabBar.appearance().barStyle = .Black
	}
	
	struct Light {
		static let sectionColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
		
		static let backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
		// grey 99
		static let oddRowColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
		// white smoke
		static let evenRowColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
		
		static let textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		// sgi gray 32
		static let authorColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
		static let descriptionColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
		static let selectedBackgroudColor = UIColor.lightGrayColor()
		
		static let poweredLabelColor = UIColor.darkGrayColor()
	}
	
	struct Dark {
		static let sectionColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
		
		// black
		static let backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		static let oddRowColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		// sgi gray 12
		static let evenRowColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 30.0/255.0, alpha: 1)

		static let textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
		// white smoke
		static let authorColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
		static let descriptionColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
		static let selectedBackgroudColor = UIColor.darkGrayColor()
		
		static let poweredLabelColor = UIColor.lightGrayColor()
	}
}