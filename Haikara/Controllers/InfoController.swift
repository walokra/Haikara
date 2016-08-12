//
//  InfoController.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class InfoController: UIViewController {

	@IBOutlet weak var aboutLabel: UILabel!
	@IBOutlet weak var licenseLabel: UILabel!

	@IBOutlet weak var openAppStoreCell: UICollectionViewCell!
    @IBOutlet weak var infoLabel: UILabel!
    @IBAction func openHighFi(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://high.fi/")!)
    }

	@IBOutlet weak var appStoreButton: UIButton!
	@IBAction func openAppStore(sender: UIButton) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://itunes.apple.com/us/app/highkara-uutislukija/id1035170336")!)
	}
	
	@IBOutlet weak var openTwitterButton: UIButton!
	@IBAction func openTwitter(sender: AnyObject) {
		let url = NSURL(string: "twitter://user?screen_name=walokra")
		if UIApplication.sharedApplication().canOpenURL(url!) {
			UIApplication.sharedApplication().openURL(url!)
		} else {
	        UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/walokra")!)
		}
	}
	
	@IBOutlet weak var bugsButton: UIButton!
	@IBAction func bugsButtonAction(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/walokra/haikara/issues")!)
	}
	
	@IBOutlet weak var openEmailButton: UIButton!
	@IBAction func openEmail(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "mailto:marko.wallin@iki.fi")!)
	}
	
	@IBOutlet weak var poweredByLabel: UILabel!
	@IBOutlet weak var poweredByButton: UIButton!
	@IBOutlet weak var feedbackLabel: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setObservers()
		
		NSNotificationCenter.defaultCenter().postNotificationName("themeChangedNotification", object: nil, userInfo: nil)
		
        let settings = Settings()
		
        infoLabel.text = settings.appID + ", Marko Wallin"
	}
	
	func setObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(InfoController.setTheme(_:)), name: "themeChangedNotification", object: nil)
	}
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("Received themeChangedNotification")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
		aboutLabel.textColor = Theme.textColor
		licenseLabel.textColor = Theme.textColor
		appStoreButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		poweredByLabel.textColor = Theme.textColor
		poweredByButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		feedbackLabel.textColor = Theme.textColor
		bugsButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		openTwitterButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)
		openEmailButton.setTitleColor(Theme.buttonColor, forState: UIControlState.Normal)

		infoLabel.textColor = Theme.textColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
