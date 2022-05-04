//
//  AppDelegate.swift
//  Haikara
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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	var openUrl: URL? // used to save state when App is not running before the url triggered
	
	override init() {
        super.init()
        _ = Settings()
    }
	
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		setObservers()
		
        setCache()
		
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.preferredDisplayMode = .allVisible

		let minimumWidth: CGFloat = min(splitViewController.view.bounds.width,splitViewController.view.bounds.height);
		splitViewController.minimumPrimaryColumnWidth = minimumWidth / 2;
		splitViewController.maximumPrimaryColumnWidth = minimumWidth;

        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! MasterViewController
        
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! DetailViewController
        
        masterViewController.delegate = detailViewController

        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        
        return true
    }

	// iOS 9
	func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
		return parseAndOpenUrl(url)
	}
	
	func parseAndOpenUrl(_ url: URL) -> Bool {
		let url = url.standardized
		let urlString = url.absoluteString
		let host = url.host

		#if DEBUG
            print("openURL, url=\(String(describing: url))")
			print("openURL, urlString=\(String(describing: urlString))")
			print("openURL, host=\(String(describing: host))")
        #endif
		
		if host!.range(of: "article") != nil {
			let webUrl = urlString.replacingOccurrences(of: "Highkara://article?url=", with: "", options: NSString.CompareOptions.literal, range: nil)
			NotificationCenter.default.post(name: .handleOpenURL, object: webUrl)
   			self.openUrl = url
   			return true
    	} else {
			#if DEBUG
				print("openURL, FAIL!")
			#endif
		}

		return false

	}

	func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.setTheme(_:)), name: .themeChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.optOutAnalytics(_:)), name: .optOutAnalyticsChangedNotification, object: nil)
	}
	
	func setTheme() {
		#if DEBUG
            print("AppDelegate, setTheme()")
        #endif
		Theme.loadTheme()
		
		// We have to set the tint colors for nav controllers manually as they are already created
		let splitViewController = self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController

		leftNavController.navigationBar.barTintColor = Theme.backgroundColor
		leftNavController.navigationBar.tintColor = Theme.tintColor
		rightNavController.navigationBar.barTintColor = Theme.backgroundColor
		rightNavController.navigationBar.tintColor = Theme.tintColor
		leftNavController.navigationBar.barStyle = Theme.barStyle
		rightNavController.navigationBar.barStyle = Theme.barStyle
	}
	
	@objc func setTheme(_ notification: Notification) {
        #if DEBUG
            print("AppDelegate, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	@objc func optOutAnalytics(_ notification: Notification) {
        #if DEBUG
            print("AppDelegate, Received optOutAnalyticsChangedNotification")
        #endif
	}
	
    // http://nshipster.com/nsurlcache/
    func setCache() {
        let cacheSizeMemory = 8 * 1024 * 1024
        let cacheSizeDisk = 40 * 1024 * 1024
        let cache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "HighkaraCache")
        URLCache.shared = cache
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	// stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

