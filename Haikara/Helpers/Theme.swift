//
//  Theme.swift
//  highkara
//
//  Created by Marko Wallin on 23.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

struct Theme {
	
	static var textColor: UIColor = Light.textColor
	static var sectionColor: UIColor = Light.sectionColor
	static var backgroundColor: UIColor = Light.backgroundColor
	static var evenRowColor: UIColor = Light.evenRowColor
	static var oddRowColor: UIColor = Light.oddRowColor
	static var cellTitleColor: UIColor = Light.textColor
	static var cellAuthorColor: UIColor = Light.authorColor
	static var cellDescriptionColor: UIColor = Light.descriptionColor
	static var selectedCellBackground = UIView()
	static var barStyle: UIBarStyle = UIBarStyle.Default
	static var statusBarStyle: UIStatusBarStyle = UIStatusBarStyle.Default
	static var searchBarTintColor: UIColor = Light.backgroundColor
	
	static var buttonColor: UIColor = Light.buttonColor
	static var tintColor: UIColor = Light.tintColor
	static var selectedColor = Light.selectedColor
	static var starColor = Light.starColor
	static var sectionTitleColor = Light.sectionTitleColor
	
	static var poweredLabelColor: UIColor = Light.poweredLabelColor
	
	static func loadTheme(){
		let defaults: NSUserDefaults = NSUserDefaults.init(suiteName: "group.com.ruleoftech.highkara")!
	
		setFonts()
		
		if let useDarkTheme: Bool = defaults.objectForKey("useDarkTheme")?.boolValue {
			(useDarkTheme) ? themeDark() : themeLight()
		} else {
			themeLight()
		}
    }
	
	static func setFonts() {
		if Settings.sharedInstance.useSystemSize {
			Settings.sharedInstance.fontSizeXLarge = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
			Settings.sharedInstance.fontSizeLarge = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
			Settings.sharedInstance.fontSizeSmall = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
			Settings.sharedInstance.fontSizeMedium = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
		} else {
			Settings.sharedInstance.fontSizeXLarge = UIFont.systemFontOfSize(Settings.sharedInstance.fontSizeBase + 6.0)
			Settings.sharedInstance.fontSizeLarge = UIFont.systemFontOfSize(Settings.sharedInstance.fontSizeBase + 5.0)
			Settings.sharedInstance.fontSizeSmall = UIFont.systemFontOfSize(Settings.sharedInstance.fontSizeBase + 2.0)
			Settings.sharedInstance.fontSizeMedium = UIFont.systemFontOfSize(Settings.sharedInstance.fontSizeBase + 3.0)
		}
	}
	
	// MARK: Light Theme Schemes
	static func themeLight(){
		textColor = Light.textColor
		backgroundColor = Light.backgroundColor

		sectionColor = Light.sectionColor
		evenRowColor = Light.evenRowColor
		oddRowColor = Light.oddRowColor
		cellTitleColor = Light.textColor
		cellAuthorColor = Light.authorColor
		cellDescriptionColor = Light.descriptionColor
		selectedCellBackground.backgroundColor = Light.selectedBackgroudColor
		
		poweredLabelColor = Light.poweredLabelColor
		
		tintColor = Light.tintColor
		searchBarTintColor = Light.backgroundColor
		barStyle = UIBarStyle.Default
		statusBarStyle = UIStatusBarStyle.Default

		UIApplication.sharedApplication().delegate?.window??.tintColor = tintColor
		UINavigationBar.appearance().barStyle = barStyle
		UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle, animated: true)
		UITabBar.appearance().barStyle = barStyle
		
		buttonColor = Light.buttonColor
		selectedColor = Light.selectedColor
		
		UISwitch.appearance().onTintColor = tintColor.colorWithAlphaComponent(0.3)
		UISwitch.appearance().thumbTintColor = tintColor
		
		starColor = Light.starColor
		sectionTitleColor = Light.sectionTitleColor
	}

	// MARK: Dark Theme Schemes
	static func themeDark(){
		textColor = Dark.textColor
		backgroundColor = Dark.backgroundColor
		
		sectionColor = Dark.sectionColor
		evenRowColor = Dark.evenRowColor
		oddRowColor = Dark.oddRowColor
		cellTitleColor = Dark.textColor
		cellAuthorColor = Dark.authorColor
		cellDescriptionColor = Dark.descriptionColor
		selectedCellBackground.backgroundColor = Dark.selectedBackgroundColor
		
		poweredLabelColor = Dark.poweredLabelColor
		
		tintColor = Dark.tintColor
		searchBarTintColor = Dark.backgroundColor
		barStyle = UIBarStyle.Black
		statusBarStyle = UIStatusBarStyle.LightContent
		
		UIApplication.sharedApplication().delegate?.window??.tintColor = tintColor
		UINavigationBar.appearance().barStyle = barStyle
		UIApplication.sharedApplication().setStatusBarStyle(statusBarStyle, animated: true)
		UITabBar.appearance().barStyle = barStyle
		
		buttonColor = Dark.buttonColor
		selectedColor = Dark.selectedColor
		
		UISwitch.appearance().onTintColor = tintColor.colorWithAlphaComponent(0.3)
		UISwitch.appearance().thumbTintColor = tintColor
		
		starColor = Dark.starColor
		sectionTitleColor = Dark.sectionTitleColor
	}
	
	struct Light {
		static let sectionColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
		static let sectionTitleColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		
		static let backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
		// grey 99
		static let oddRowColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
		// sgi gray 92
		static let evenRowColor = UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1)
		
		static let textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		// sgi gray 32
		static let authorColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
		static let descriptionColor = UIColor(red: 81.0/255.0, green: 81.0/255.0, blue: 81.0/255.0, alpha: 1)
		static let selectedBackgroudColor = UIColor.lightGrayColor()
		
		static let poweredLabelColor = UIColor.darkGrayColor()

		// orange
		static let buttonColor = UIColor(red: 242.0/255.0, green: 137.0/255.0, blue: 32.0/255.0, alpha: 1.0)
		static let tintColor = UIColor(red: 242.0/255.0, green: 137.0/255.0, blue: 32.0/255.0, alpha: 1.0)
		// high green
		static let selectedColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
		static let starColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
	}
	
	struct Dark {
		// darker green, #21474e
		static let sectionColor = UIColor(red: 33.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
		static let sectionTitleColor = UIColor(red: 171.0/255.0, green: 203.0/255.0, blue: 209.0/255.0, alpha: 1)
		
		// black
		static let backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		static let oddRowColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		// #1f1f1f
		static let evenRowColor = UIColor(red: 31.0/255.0, green: 31.0/255.0, blue: 31.0/255.0, alpha: 1)

		static let textColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
		// #8c8c8c
		static let authorColor = UIColor(red: 140.0/255.0, green: 140.0/255.0, blue: 140.0/255.0, alpha: 1)
		// #c0c0c0
		static let descriptionColor = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1)
		static let selectedBackgroundColor = UIColor.darkGrayColor()
		
		static let poweredLabelColor = UIColor.lightGrayColor()
		
		// orange
		static let buttonColor = UIColor(red: 171.0/255.0, green: 97.0/255.0, blue: 23.0/255.0, alpha: 1.0)
		static let tintColor = UIColor(red: 171.0/255.0, green: 97.0/255.0, blue: 23.0/255.0, alpha: 1.0)
		// darker green, #21474e
		static let selectedColor = UIColor(red: 33.0/255.0, green: 71.0/255.0, blue: 78.0/255.0, alpha: 1)
		// darker green, #21474e
		static let starColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
	}
	
}
