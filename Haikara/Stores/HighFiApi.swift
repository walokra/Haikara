//
//  HighFiApi.swift
//  Haikara
//
//  Created by Marko Wallin on 29.8.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

import Alamofire

public class HighFiApi {
    
    // Getting news from High.fi and return values to blocks as completion handlers, completion closure (callback)
    class func getNews(page: Int, section: String, completionHandler: ([Entry]) -> Void, failureHandler: (String) -> Void) {
        
        #if DEBUG
            print("HighFiApi.getNews: \(page), \(section)")
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
        
        var categoriesHidden: Array<Int> = []
        var categoriesHiddenParam: String = ""
        if (!settings.categoriesHidden.isEmpty && settings.categoriesHidden[settings.region] != nil) {
            categoriesHidden = settings.categoriesHidden[settings.region]!
            // categoriesHidden.description
            categoriesHidden.forEach({ (item) -> () in
                categoriesHiddenParam += String(item)
                if categoriesHidden.count > 1 {
                    categoriesHiddenParam += ","
                }
            })
        }
//        print("categoriesHidden=\(categoriesHidden)")
        
        let request = Manager.sharedInstance.request(.GET, feed, parameters: ["APIKEY": settings.APIKEY, "jsonHideSections": categoriesHiddenParam])

            request.validate()
            request.responseJSON{(request, response, result) in
            switch result {
            case .Success(let data):
                #if DEBUG
                    print("HighFiApi, request: \(request)")
//                    print("response: \(response)")
//                    print("json: \(data)")
                #endif
				
				
				var newsSourcesFiltered = [Int]()
				if settings.newsSourcesFiltered[settings.region] != nil {
					newsSourcesFiltered = settings.newsSourcesFiltered[settings.region]!
				}
				
                let responseData = (data.valueForKey("responseData") as! NSDictionary)
                let feed = (responseData.valueForKey("feed") as! NSDictionary)
                let entries: [Entry] = (feed.valueForKey("entries") as! [NSDictionary])
                    .filter({ !newsSourcesFiltered.contains($0["sourceID"] as! Int) })
                    .map { Entry(
                        title: $0["title"] as! String,
                        link: $0["link"] as! String,
                        clickTrackingLink: $0["clickTrackingLink"] as! String,
                        author: $0["author"] as! String,
                        publishedDateJS: $0["publishedDateJS"] as! String,
                        shortDescription: $0["shortDescription"] as? String,
                        originalURL: $0["originalURL"] as! String,
                        mobileLink: $0["mobileLink"] as? String,
                        originalMobileUrl: $0["originalMobileUrl"] as?	String,
                        shareURL: $0["shareURL"] as! String,
                        mobileShareURL: $0["mobileShareURL"] as? String,
                        //	let picture: String?
                        //	let originalPicture: String?
                        articleID: $0["articleID"] as! Int,
                        sectionID: $0["sectionID"] as! Int,
                        sourceID: $0["sourceID"] as! Int,
                        highlight: $0["highlight"] as! Bool,
                        timeSince: "Juuri nyt"
                        )
                }
                // println("entries: \(entries.count)")
                
                return completionHandler(entries)

            case .Failure(let data, let error):
                #if DEBUG
                    print("Error: \(__FUNCTION__)\n", data, error)
                #endif
                if let error = result.error as? NSError {
                    failureHandler(error.localizedDescription)
                }
            }
        }
    }
    
    class func trackNewsClick(link: String) {
        #if DEBUG
            print("HighFiApi.trackNewsClick(\(link))")
        #endif
        let settings = Settings.sharedInstance
        
        Alamofire.request(.GET, link, parameters: ["APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
            .response { (request, response, data, error) in
                #if DEBUG
                    print(request)
                    // println(response)
                    // println(error)
                #endif
        }
    }
    
    class func getCategories(completionHandler: (Array<Category>) -> Void, failureHandler: (String) -> Void) {
        #if DEBUG
            print("HighFiApi.getCategories()")
        #endif
        
        let settings = Settings.sharedInstance
        
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=84600"
        ]

        let url = "http://" + settings.domainToUse + "/api/"
        
        let request = Manager.sharedInstance.request(.GET, url, parameters: ["act": settings.highFiActCategory, "usedLanguage": settings.useToRetrieveLists, "APIKEY": settings.APIKEY])
        request.validate()
        request.responseJSON {request, response, result in
            switch result {
            case .Success(let data):
                #if DEBUG
                    print("HighFiApi, request: \(request)")
//                    println("response: \(response)")
//                    print("json: \(data)")
                #endif

                let responseData = (data.valueForKey("responseData") as! NSDictionary)
                let categories = (responseData.valueForKey("categories") as! [NSDictionary])
//                    .filter({ ($0["depth"] as! Int) == 1 })
                    .map { Category(
                        title: $0["title"] as! String,
                        sectionID: $0["sectionID"] as! Int,
                        depth: $0["depth"] as! Int,
                        htmlFilename: $0["htmlFilename"] as! String,
                        selected: false
                        )
                    }
                
//                // HACK for dealing with missing values from API
//                var categories = [Category]()
//                let responseData = (data.valueForKey("responseData") as! NSDictionary)
//                let cats = responseData.valueForKey("categories") as! [NSDictionary]
//                for category in cats {
//                    var title: String = ""
//                    var sectionID: Int = 0
//                    var depth: Int = 0
//                    var htmlFilename: String = ""
//                    if let t = category["title"] as? String {
//                        title = t
//                    }
//                    if let sid = category["sectionID"] as? Int {
//                        sectionID = sid
//                    }
//                    if let d = category["depth"] as? Int {
//                        depth = d
//                    }
//                    if let html = category["htmlFilename"] as? String {
//                        htmlFilename = html
//                    }
//                    
//                    // Checking for needed information
//                    if title != "" && sectionID != 0 && htmlFilename != "" {
//                        let cat = Category(title: title, sectionID: sectionID, depth: depth, htmlFilename: htmlFilename, selected: false)
//                        
//                        categories.append(cat)
//                    }
//                }
                // println("categories: \(categories.count)")
                
                return completionHandler(categories)
            case .Failure(let data, let error):
                #if DEBUG
                    print("Error: \(__FUNCTION__)\n", data, error)
                #endif
                if let error = result.error as? NSError {
                    failureHandler(error.localizedDescription)
                }
        }
        }
    }

    // You should cache this method's return value for min 24h
    // http://high.fi/api/?act=listLanguages&APIKEY=123
    class func listLanguages(completionHandler: ([Language]) -> Void, failureHandler: (String) -> Void) {
        #if DEBUG
            print("HighFiApi.listLanguages()")
        #endif
    
        let settings = Settings.sharedInstance
    
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=84600"
        ]
        
        let url = "http://" + settings.domainToUse + "/api"
        
        let request = Manager.sharedInstance.request(.GET, url, parameters: ["act":"listLanguages", "APIKEY": settings.APIKEY])
        request.validate()
        request.responseJSON {request, response, result in
            switch result {
            case .Success(let data):

                #if DEBUG
                    print("HighFiApi, request: \(request)")
                    // println("response: \(response)")
                    // println("json: \(theJSON)")
                #endif
            
                let responseData = (data.valueForKey("responseData") as! NSDictionary)
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
                        print("HighFiApi, languages: \(languages.count)")
                        //println("languages: \(languages)")
                    #endif
                
                return completionHandler(languages)
                
            case .Failure(let data, let error):
                #if DEBUG
                    print("Error: \(__FUNCTION__)\n", data, error)
                #endif
                if let error = result.error as? NSError {
                    failureHandler(error.localizedDescription)
                }
            }
        }
    }
	
    // http://high.fi/api/?act=listSources&usedLanguage=Finnish&APIKEY=123
    class func listSources(completionHandler: ([NewsSources]) -> Void, failureHandler: (String) -> Void) {
        #if DEBUG
            print("listSources()")
        #endif
    
        let settings = Settings.sharedInstance
    
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=84600"
        ]
        
        let url = "http://" + settings.domainToUse + "/api"
        
        let request = Manager.sharedInstance.request(.GET, url, parameters: ["act":"listSources", "usedLanguage":settings.useToRetrieveLists, "APIKEY":settings.APIKEY])
        request.validate()
        request.responseJSON {request, response, result in
            switch result {
            case .Success(let data):

                #if DEBUG
                    print("HighFiApi, request: \(request)")
                    // println("response: \(response)")
                    // println("json: \(theJSON)")
                #endif
            
                let responseData = (data.valueForKey("responseData") as! NSDictionary)
                let newsSources = (responseData.valueForKey("newsSources") as! [NSDictionary])
                    .map { NewsSources(
                        sourceName: $0["sourceName"] as! String,
                        sourceID: $0["sourceID"] as! Int,
						selected: false
                        )
                    }
                    #if DEBUG
                        print("HighFiApi, newsSources: \(newsSources.count)")
                    #endif
                
                return completionHandler(newsSources)
                
            case .Failure(let data, let error):
                #if DEBUG
                    print("Error: \(__FUNCTION__)\n", data, error)
                #endif
                if let error = result.error as? NSError {
                    failureHandler(error.localizedDescription)
                }
            }
        }
    }
}
