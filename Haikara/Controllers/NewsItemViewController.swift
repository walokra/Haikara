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

	let viewName = "NewsItemView"

    @IBOutlet var containerView: UIView? = nil
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
		setTheme()
    }
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.webView?.backgroundColor = Theme.backgroundColor
    }
    
    func loadWebView(url: NSURL) {
        self.webView = WKWebView()
        self.view = self.webView
        
        webView!.loadRequest(NSURLRequest(URL: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

