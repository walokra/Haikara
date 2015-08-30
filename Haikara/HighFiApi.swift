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
    class func getNews(page: Int, section: String, completionHandler:(result: Array<Entry>) -> Void) {
        #if DEBUG
            println("HighFiApi.getNews: \(page), \(section)")
        #endif
        
        let settings = Settings.sharedInstance
        
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=60"
        ]

        var feed = "http://" + settings.domainToUse + "/" + section + "/"
        if (page != 1) {
            feed = feed + String(page) + "/"
        }
        feed = feed + settings.highFiEndpoint
        
        // Alamofire.request is non-blocking call so we cannot return from this function
        // using the completion handler to return values
        Manager.sharedInstance.request(.GET, feed, parameters: ["APIKEY": settings.APIKEY])
            .responseJSON() { (request, response, data, error: NSError?) in
				#if DEBUG
                    println("HighFiApi, request: \(request)")
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
                        
                        completionHandler(result: entries)
                    }
                } else {
                    #if DEBUG
                        println("HighFiApi, error: \(error)")
                    #endif
                    self.showError(error!.localizedDescription)
                }
        }
    }
    
    class func trackNewsClick(link: String) {
        #if DEBUG
            println("HighFiApi.trackNewsClick(\(link))")
        #endif
        let settings = Settings.sharedInstance
        
        Alamofire.request(.GET, link, parameters: ["APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
            .response { (request, response, data, error) in
                #if DEBUG
                    println(request)
                    //						println(response)
                    //						println(error)
                #endif
        }
    }
    
    class func getCategories(completionHandler:(result: [Category]) -> Void) {
        #if DEBUG
            println("HighFiApi.getCategories()")
        #endif
        
        let settings = Settings.sharedInstance
        
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=84600"
        ]

        let url = "http://" + settings.domainToUse + "/api/"
        
        Manager.sharedInstance.request(.GET, url, parameters: ["act": settings.highFiActCategory, "usedLanguage": settings.useToRetrieveLists, "APIKEY": settings.APIKEY])
            .responseJSON() { (request, response, JSON, error: NSError?) in
                #if DEBUG
                    println("HighFiApi, request: \(request)")
                    // println("response: \(response)")
                    // println("json: \(theJSON)")
                #endif
                
                if error == nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let data = (JSON!.valueForKey("responseData") as! NSDictionary)
                        var categories = (data.valueForKey("categories") as! [NSDictionary])
                            .filter({ ($0["depth"] as! Int) == 1 })
                            .map { Category(
                                title: $0["title"] as! String,
                                sectionID: $0["sectionID"] as! Int,
                                depth: $0["depth"] as! Int,
                                htmlFilename: $0["htmlFilename"] as! String
                                )
                        }
                        //                        println("categories: \(categories.count)")
                        
                        // Adding always present categories: generic and top
                        var cat = [Category]()
                        cat.append(Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart))
                        cat.append(Category(title: settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top"))
                        
                        completionHandler(result: cat + categories)
                    }
                } else {
                    #if DEBUG
                        println("HighFiApi, error: \(error)")
                    #endif
                    self.showError(error!.localizedDescription)
                }
        }
    }
    
    // You should cache this method's return value for min 24h
    // http://high.fi/api/?act=listLanguages&APIKEY=123
    class func listLanguages(completionHandler:(result: Array<Language>) -> Void) {
        #if DEBUG
            println("HighFiApi.listLanguages()")
        #endif
    
        let settings = Settings.sharedInstance
    
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=84600"
        ]
        
        let endpoint = "http://" + settings.domainToUse + "/api"
        
        Manager.sharedInstance.request(.GET, endpoint, parameters: ["act":"listLanguages", "APIKEY": settings.APIKEY])
            .responseJSON() { (request, response, data, error) in
                #if DEBUG
                    println("HighFiApi, request: \(request)")
                    //                println("response: \(response)")
                    //                println("json: \(data)")
                #endif
                
                if error == nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let responseData = (data!.valueForKey("responseData") as! NSDictionary)
                        let languages = (responseData.valueForKey("supportedLanguages") as! [NSDictionary])
                            .map { Language(
                                language: $0["language"] as! String,
                                country: $0["country"] as! String,
                                domainToUse: $0["domainToUse"] as! String,
                                languageCode: $0["languageCode"] as! String,
                                mostPopularName: $0["mostPopularName"] as! String,
                                latestName: $0["latestName"] as! String,
                                useToRetrieveLists: $0["useToRetrieveLists"] as!	String,
                                genericNewsURLPart: $0["genericNewsURLPart"] as! String
                                )
                        }
                        #if DEBUG
                            println("HighFiApi, languages: \(languages.count)")
//                            println("languages: \(languages)")
                        #endif
                        
                        completionHandler(result: languages)
                    }
                } else {
                    #if DEBUG
                        println("HighFiApi, error: \(error)")
                    #endif
                    self.showError(error!.localizedDescription)
                }
        }
    }
    
    class func showError(errormsg: String) {
        var alert = UIAlertController(title: "Error", message: "\(errormsg)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    }
}
