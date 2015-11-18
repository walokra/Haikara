//
//  InfoController.swift
//  Haikara
//
//  Created by Marko Wallin on 28.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class InfoController: UIViewController {

	var appStoreButtonText: String = NSLocalizedString("INFO_REVIEW_TITLE", comment: "Review in app store")
	var bugsButtonText: String = NSLocalizedString("INFO_BUGS_TITLE", comment: "Bug reports")

    @IBOutlet weak var infoLabel: UILabel!
    @IBAction func openHighFi(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://high.fi/")!)
    }
	
	@IBOutlet weak var appStoreLabel: UIButton!
	@IBAction func openAppStore(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://itunes.apple.com/us/app/highkara-uutislukija/id1035170336")!)
	}
	
	@IBAction func openTwitter(sender: AnyObject) {
		let url = NSURL(string: "twitter://user?screen_name=walokra")
		if UIApplication.sharedApplication().canOpenURL(url!) {
			UIApplication.sharedApplication().openURL(url!)
		} else {
	        UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/walokra")!)
		}
	}
	
	@IBOutlet weak var bugsLabel: UIButton!
	@IBAction func openGitHub(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "https://github.com/walokra/haikara/issues")!)
	}
	
	@IBAction func openEmail(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "mailto:marko.wallin@iki.fi")!)
	}
	
	
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = Settings()

        infoLabel.text = settings.appID + ", Marko Wallin"
		appStoreLabel.setTitle(appStoreButtonText, forState: UIControlState.Normal)
		bugsLabel.setTitle(bugsButtonText, forState: UIControlState.Normal)
		
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
