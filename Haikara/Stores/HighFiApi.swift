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
	
	class func setupManager(appID: String, maxAge: Int) {
//	    // Create a custom configuration
//      let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//		var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
//		defaultHeaders!["User-Agent"] = appID
//		defaultHeaders!["Cache-Control"] = "private, must-revalidate, max-age=\(maxAge)"
//      config.HTTPAdditionalHeaders = defaultHeaders
//		config.requestCachePolicy = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
//		config.URLCache = NSURLCache.sharedURLCache()
//		let manager = Alamofire.Manager(configuration: config)
//		
//		return manager

        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": appID,
            "Cache-Control": "private, must-revalidate, max-age=\(maxAge)"
        ]
	}
	
	class func search(searchText: String, completionHandler: ([Entry]) -> Void, failureHandler: (String) -> Void) {
		#if DEBUG
            print("HighFiApi.search: \(searchText)")
        #endif
    	// http://high.fi/search.cfm?q=formula&x=0&y=0&outputtype=json-private
    	let settings = Settings.sharedInstance
		setupManager(settings.appID, maxAge: 60)

        let feed = "http://" + settings.domainToUse + "/search.cfm"
		
		let request = Alamofire.request(.GET, feed, parameters: ["q": searchText, "x": 0, "y": 0, "outputtype": settings.highFiEndpoint, "APIKEY": settings.APIKEY])

            request.validate()
            request.responseJSON{ response in
            switch response.result {
            case .Success(let data):
                #if DEBUG
                    print("HighFiApi, request: \(response.request)")
//                    print("HighFiApi, response: \(response.response)")
//                    print("HighFiApi, data: \(response.data)")
                #endif
				
                let responseData = (data.valueForKey("responseData") as! NSDictionary)
                let feed = (responseData.valueForKey("feed") as! NSDictionary)
                let entries: [Entry] = (feed.valueForKey("entries") as! [NSDictionary])
                    .map { Entry(
                        title: $0["title"] as! String,
                        link: $0["link"] as! String,
                        clickTrackingLink: $0["clickTrackingLink"] as! String,
                        author: $0["author"] as! String,
                        publishedDateJS: $0["publishedDateJS"] as! String,
						picture: $0["picture"] as? String,
                        originalPicture: $0["originalPicture"] as? String,
                        shortDescription: $0["shortDescription"] as? String,
                        originalURL: $0["originalURL"] as! String,
                        mobileLink: $0["mobileLink"] as? String,
                        originalMobileUrl: $0["originalMobileUrl"] as?	String,
                        shareURL: $0["shareURL"] as! String,
                        mobileShareURL: $0["mobileShareURL"] as? String,
                        articleID: $0["articleID"] as! Int,
                        sectionID: $0["sectionID"] as! Int,
                        sourceID: $0["sourceID"] as! Int,
                        highlight: $0["highlight"] as! Bool,
						highlightType: $0["highlightType"] as! String,
                        timeSince: "Juuri nyt",
						orderNro: 0
                        )
                }
//				print("entries: \(entries.count)")
				
                return completionHandler(entries)

            case .Failure(let error):
                #if DEBUG
                    print("Error: \(#function)\n", error)
                #endif
				failureHandler(error.localizedDescription)
            }
        }
	}

    // Getting news from High.fi and return values to blocks as completion handlers, completion closure (callback)
	// e.g. http://high.fi/uutiset/json-private
    class func getNews(page: Int, section: String, completionHandler: ([Entry]) -> Void, failureHandler: (String) -> Void) {
        
        #if DEBUG
            print("HighFiApi.getNews: \(page), \(section)")
        #endif
        
        let settings = Settings.sharedInstance
		setupManager(settings.appID, maxAge: 60)

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
		
        let request = Alamofire.request(.GET, feed, parameters: ["APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID, "jsonHideSections": categoriesHiddenParam])

            request.validate()
            request.responseJSON{ response in
            switch response.result {
            case .Success(let data):
                #if DEBUG
                    print("HighFiApi, request: \(response.request)")
//                    print("HighFiApi, response: \(response.response)")
//                    print("HighFiApi, data: \(response.data)")
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
						picture: $0["picture"] as? String,
                        originalPicture: $0["originalPicture"] as? String,
                        shortDescription: $0["shortDescription"] as? String,
                        originalURL: $0["originalURL"] as! String,
                        mobileLink: $0["mobileLink"] as? String,
                        originalMobileUrl: $0["originalMobileUrl"] as?	String,
                        shareURL: $0["shareURL"] as! String,
                        mobileShareURL: $0["mobileShareURL"] as? String,
                        articleID: $0["articleID"] as! Int,
                        sectionID: $0["sectionID"] as! Int,
                        sourceID: $0["sourceID"] as! Int,
                        highlight: $0["highlight"] as! Bool,
						highlightType: $0["highlightType"] as! String,
                        timeSince: "Juuri nyt",
						orderNro: 0
                        )
                }
                // println("entries: \(entries.count)")
                
                return completionHandler(entries)

            case .Failure(let error):
                #if DEBUG
                    print("Error: \(#function)\n", error)
                #endif
				failureHandler(error.localizedDescription)
            }
        }
    }
	
	// make a silent HTTP GET request to the click tracking URL provided in the JSON's link field
    class func trackNewsClick(link: String) {
        #if DEBUG
            print("HighFiApi.trackNewsClick(\(link))")
        #endif
        let settings = Settings.sharedInstance
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        	Alamofire.request(.GET, link, parameters: ["APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
	            .response { request, response, data, error in
    	            #if DEBUG
        	            print("trackNewsClick, request: \(request)")
            	        // print("trackNewsClick, response: \(response)")
                	    // print("trackNewsClick, error: \(error)")
                	#endif
	        }
		}
    }
	
	// e.g. http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
    class func getCategories(completionHandler: (Array<Category>) -> Void, failureHandler: (String) -> Void) {
        #if DEBUG
            print("HighFiApi.getCategories()")
        #endif
        
        let settings = Settings.sharedInstance
        setupManager(settings.appID, maxAge: 84600)

        let url = "http://" + settings.domainToUse + "/api/"
        
        let request = Alamofire.request(.GET, url, parameters: ["act": settings.highFiActCategory, "usedLanguage": settings.useToRetrieveLists, "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
            switch response.result {
            case .Success(let data):
                #if DEBUG
                    print("HighFiApi, request: \(response.request)")
//                    print("HighFiApi, response: \(response.response)")
//                    print("HighFiApi, data: \(response.data)")
                #endif

                let responseData = (data.valueForKey("responseData") as! NSDictionary)
				
				// Add always found categories to the list
				var cat = [Category]()
				cat.append(Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart, highlight: false, selected: true))
        		cat.append(Category(title: settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top", highlight: false, selected: true))
				
                let categories = (responseData.valueForKey("categories") as! [NSDictionary])
//                    .filter({ ($0["depth"] as! Int) == 1 })
                    .map { Category(
                        title: $0["title"] as! String,
                        sectionID: $0["sectionID"] as! Int,
                        depth: $0["depth"] as! Int,
                        htmlFilename: $0["htmlFilename"] as! String,
						highlight: $0["highlight"] as! Bool,
                        selected: false
                        )
                    }
                
                return completionHandler(cat + categories)
            case .Failure(let error):
                #if DEBUG
                    print("Error: \(#function)\n", error)
                #endif
				failureHandler(error.localizedDescription)
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
    	setupManager(settings.appID, maxAge: 84600)
	
        let url = "http://" + settings.domainToUse + "/api"
        
        let request = Alamofire.request(.GET, url, parameters: ["act":"listLanguages", "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
            switch response.result {
            case .Success(let data):

                #if DEBUG
                    print("HighFiApi, request: \(response.request)")
                    // print("HighFiApi, response: \(response.response)")
                    // print("HighFiApi, data: \(response.data)")
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
                
            case .Failure(let error):
                #if DEBUG
                    print("Error: \(#function)\n", error)
                #endif
				failureHandler(error.localizedDescription)
            }
        }
    }
	
    // http://high.fi/api/?act=listSources&usedLanguage=Finnish&APIKEY=123
    class func listSources(completionHandler: ([NewsSources]) -> Void, failureHandler: (String) -> Void) {
        #if DEBUG
            print("listSources()")
        #endif
    
        let settings = Settings.sharedInstance
    	setupManager(settings.appID, maxAge: 84600)
        
        let url = "http://" + settings.domainToUse + "/api"
        
        let request = Alamofire.request(.GET, url, parameters: ["act":"listSources", "usedLanguage":settings.useToRetrieveLists, "APIKEY":settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
            switch response.result {
            case .Success(let data):

                #if DEBUG
                    print("HighFiApi, request: \(response.request)")
                    // print("HighFiApi, response: \(response.response)")
                    // print("HighFiApi, data: \(response.theJSON)")
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
                
            case .Failure(let error):
                #if DEBUG
                    print("Error: \(#function)\n", error)
                #endif
				failureHandler(error.localizedDescription)
            }
        }
    }
}
