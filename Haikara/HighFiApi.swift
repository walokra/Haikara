//
//  HighFiApi.swift
//  Haikara
//
//  Created by Marko Wallin on 29.8.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

import Alamofire

class HighFiApi {
    
    // Getting news from High.fi and return values to blocks as completion handlers, completion closure (callback)
    class func getNews(page: Int, section: String, completion:(result: Array<Entry>) -> Void) {
        #if DEBUG
            println("getNews: \(page), \(section)")
        #endif
   
        let settings = Settings.sharedInstance

        var feed = "http://" + settings.domainToUse + "/" + section + "/"
        if (page != 1) {
            feed = feed + String(page) + "/"
        }
        feed = feed + settings.highFiEndpoint
        
        // Alamofire.request is non-blocking call so we cannot return from this function
        // using the completion handler to return values
        Manager.sharedInstance.request(.GET, feed, parameters: ["APIKEY": settings.APIKEY])
            .responseJSON() { (request, response, data, error) in
				#if DEBUG
                    println("request: \(request)")
//					println("response: \(response)")
//					println("json: \(theJSON)")
				#endif
				
                if error == nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let responseData = (data!.valueForKey("responseData") as! NSDictionary)
                        let feed = (responseData.valueForKey("feed") as! NSDictionary)
                        let entries: Array<Entry> = (feed.valueForKey("entries") as! [NSDictionary])
                            //.filter({ ($0["sectionID"] as! Int) == 98 })
                            .map { Entry(
                                title: $0["title"] as! String,
                                link: $0["link"] as! String,
                                author: $0["author"] as! String,
                                publishedDateJS: $0["publishedDateJS"] as! String,
                                shortDescription: $0["shortDescription"] as? String,
                                originalURL: $0["originalURL"] as! String,
                                mobileLink: $0["mobileLink"] as? String,
                                originalMobileUrl: $0["originalMobileUrl"] as?	String,
                                //	let picture: String?
                                //	let originalPicture: String?
                                articleID: $0["articleID"] as! Int,
                                sectionID: $0["sectionID"] as! Int,
                                sourceID: $0["sourceID"] as! Int,
                                highlight: $0["highlight"] as! Bool,
                                timeSince: "Juuri nyt"
                                )
                        }
//                        println("entries: \(entries.count)")
                        
                        completion(result: entries)
                    }
                } else {
                    println("error: \(error)")
                    var alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                }
        }
    }
}
