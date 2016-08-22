//
//  AppDelegate.swift
//  Haikara
//
//  Created by Marko Wallin on 14.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	var openUrl: NSURL? // used to save state when App is not running before the url triggered

    static let settings = Settings()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
		
		setObservers()
		
        setCache()
        
        let splitViewController = self.window!.rootViewController as! UISplitViewController

		let minimumWidth: CGFloat = min(CGRectGetWidth(splitViewController.view.bounds),CGRectGetHeight(splitViewController.view.bounds));
		splitViewController.minimumPrimaryColumnWidth = minimumWidth / 2;
		splitViewController.maximumPrimaryColumnWidth = minimumWidth;

        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! MasterViewController
        
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! DetailViewController
        
        masterViewController.delegate = detailViewController

        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        
        return true
    }

	func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
    	let url = url.standardizedURL
		let urlString = url!.absoluteString
		let host = url!.host
//    	let query = url!.query
//    	let openUrlPath = url!.path

		#if DEBUG
            print("openURL, url=\(url)")
			print("openURL, urlString=\(urlString)")
			print("openURL, host=\(host)")
//			print("openURL, openUrlPath=\(openUrlPath)")
//			print("openURL, query=\(query)")
        #endif
		
		if host!.rangeOfString("article") != nil {
			let webUrl = urlString.stringByReplacingOccurrencesOfString("Highkara://article?url=", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
           	NSNotificationCenter.defaultCenter().postNotificationName("handleOpenURL", object: webUrl)
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppDelegate.setTheme(_:)), name: "themeChangedNotification", object: nil)
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
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("AppDelegate, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
    // http://nshipster.com/nsurlcache/
    func setCache() {
        let cacheSizeMemory = 4 * 1024 * 1024
        let cacheSizeDisk = 20 * 1024 * 1024
        let cache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: nil)
//        let cache = NSURLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "shared_cache")
        NSURLCache.setSharedURLCache(cache)
        
//        // Create a custom configuration
//        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
//        configuration.HTTPAdditionalHeaders = defaultHeaders
//        configuration.requestCachePolicy = .UseProtocolCachePolicy // this is the default
//        configuration.URLCache = cache
//        
//        // Create your own manager instance that uses your custom configuration
//        Manager(configuration: configuration)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

