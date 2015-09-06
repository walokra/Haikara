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

    @IBOutlet var containerView: UIView? = nil
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
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

//extension NewsItemViewController: LinkSelectionDelegate {
//    func linkSelected(entry: Entry) {
//        #if DEBUG
//            println("linkSelected")
//        #endif
//        self.entry = entry
//        self.loadWebView()
//    }
//}
