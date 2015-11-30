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
	
	static var buttonColor: UIColor = Light.buttonColor
	static var tintColor: UIColor = Light.tintColor
	static var selectedColor = Light.selectedColor
	
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

		// orange
		static let buttonColor = UIColor(red: 242.0/255.0, green: 137.0/255.0, blue: 32.0/255.0, alpha: 1.0)
		static let tintColor = UIColor(red: 242.0/255.0, green: 137.0/255.0, blue: 32.0/255.0, alpha: 1.0)
		// high green
		static let selectedColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
	}
	
	struct Dark {
		static let sectionColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
		
		// black
		static let backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		static let oddRowColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
		// sgi gray 16
		static let evenRowColor = UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 1)

		static let textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1)
		// white smoke
		static let authorColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
		static let descriptionColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
		static let selectedBackgroundColor = UIColor.darkGrayColor()
		
		static let poweredLabelColor = UIColor.lightGrayColor()
		
		// orange
		static let buttonColor = UIColor(red: 242.0/255.0, green: 137.0/255.0, blue: 32.0/255.0, alpha: 1.0)
		static let tintColor = UIColor(red: 242.0/255.0, green: 137.0/255.0, blue: 32.0/255.0, alpha: 1.0)
		// high green
		static let selectedColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
	}
}