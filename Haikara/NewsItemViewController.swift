//
//  NewsItemViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import WebKit

class NewsItemViewController: UIViewController {

    @IBOutlet var containerView : UIView? = nil
    var webView: WKWebView?
    var webSite: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView = WKWebView()
        self.view = self.webView
        
        if let address = webSite {
            let webURL = NSURL(string: address)
            webView!.loadRequest(NSURLRequest(URL: webURL!))
        }

        // Do any additional setup after loading the view.
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
