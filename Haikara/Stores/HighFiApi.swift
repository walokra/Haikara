//
//  HighFiApi.swift
//  Haikara
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Marko Wallin <mtw@iki.fi>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

import Alamofire

open class HighFiApi {
	
	class func setupManager(_ appID: String, maxAge: Int) {
        SessionManager.default.session.configuration.httpAdditionalHeaders = [
            "User-Agent": appID,
            "Cache-Control": "private, must-revalidate, max-age=\(maxAge)"
        ]
	}
	
	class func search(_ searchText: String, completionHandler: @escaping ([Entry]) -> Void, failureHandler: @escaping (String) -> Void) {
		#if DEBUG
            print("HighFiApi.search: \(searchText)")
        #endif
    	// https://high.fi/search.cfm?q=formula&x=0&y=0&outputtype=json-private
    	let settings = Settings.sharedInstance
		setupManager(settings.appID, maxAge: 60)

        let feed = "https://" + settings.domainToUse + "/search.cfm"
		
        let request = Alamofire.request(feed, method: .get, parameters: ["q": searchText, "x": 0, "y": 0, "includePaid": settings.includePaid, "outputtype": settings.highFiEndpoint, "APIKEY": settings.APIKEY])

            request.validate()
            request.responseJSON{ response in
			
			#if DEBUG
				debugPrint(response)
			#endif
                
            switch response.result {
                case .success:
                    // make sure we got JSON and it's an array of dictionaries
                    guard let json = response.result.value as? [String: AnyObject] else {
                        #if DEBUG
                            print("Error: \(#function)\n", response.result.error!)
                        #endif
                        
                        failureHandler("Did not get JSON array in response")
                        return
                    }
                    
                    let responseData = json["responseData"] as! NSDictionary
                    let feed = (responseData.value(forKey: "feed") as! NSDictionary)
                    
                    let entries: [Entry] = (feed.value(forKey: "entries") as! [NSDictionary])
                        .map {(element) in
                            return Entry(
                                title: element["title"] as! String,
                                link: element["link"] as! String,
                                clickTrackingLink: element["clickTrackingLink"] as! String,
                                author: element["author"] as! String,
                                publishedDateJS: element["publishedDateJS"] as! String,
                                picture: element["picture"] as? String,
                                originalPicture: element["originalPicture"] as? String,
                                shortDescription: element["shortDescription"] as? String,
                                originalURL: element["originalURL"] as! String,
                                mobileLink: element["mobileLink"] as? String,
                                originalMobileUrl: element["originalMobileUrl"] as?    String,
                                shareURL: element["shareURL"] as! String,
                                mobileShareURL: element["mobileShareURL"] as? String,
                                ampURL: element["ampURL"] as? String,
                                articleID: element["articleID"] as! Int,
                                sectionID: element["sectionID"] as! Int,
                                sourceID: element["sourceID"] as! Int,
                                highlight: element["highlight"] as! Bool,
                                highlightType: element["highlightType"] as! String,
                                timeSince: "Juuri nyt",
                                orderNro: 0
                            )
                    }
                    #if DEBUG
                        print("entries: \(entries.count)")
                    #endif
                    
                    return completionHandler(entries)

                case .failure(let error):
                    #if DEBUG
                        print("Error: \(#function)\n", error)
                    #endif
                    failureHandler(error.localizedDescription)
                    return
            }
        }
	}

    class func parseArticleID(id: Any) -> Int {
        if let id = id as? Int {
            return id
        } else {
            return (id as! NSString).integerValue
        }
    }
    
    // Getting news from High.fi and return values to blocks as completion handlers, completion closure (callback)
	// e.g. https://high.fi/uutiset/json-private
    class func getNews(_ page: Int, section: String, completionHandler: @escaping ([Entry]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("HighFiApi.getNews: \(page), \(section)")
        #endif
        
        let settings = Settings.sharedInstance
		setupManager(settings.appID, maxAge: 60)

        var feed = "https://" + settings.domainToUse + "/" + section + "/"
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
		
        let request = Alamofire.request(feed, method: .get, parameters: ["includePaid": settings.includePaid, "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID, "jsonHideSections": categoriesHiddenParam])

            request.validate()
            request.responseJSON{ response in
				
			#if DEBUG
				debugPrint(response)
			#endif

            switch response.result {
                case .success:
                    guard let json = response.result.value as? [String: AnyObject] else {
                        #if DEBUG
                            print("Error: \(#function)\n", "Did not get JSON dictionary in response")
                        #endif
                        
                        failureHandler("Did not get JSON dictionary in response")
                        return
                    }
                    
                    let responseData = json["responseData"] as! NSDictionary
                    let feed = responseData.value(forKey: "feed") as! NSDictionary
                    
                    var newsSourcesFiltered = [Int]()
                    if settings.newsSourcesFiltered[settings.region] != nil {
                        newsSourcesFiltered = settings.newsSourcesFiltered[settings.region]!
                    }

                    let entries: [Entry] = (feed.value(forKey: "entries") as! [NSDictionary])
                        .filter({ !newsSourcesFiltered.contains($0["sourceID"] as! Int) })
                        .map {(element) in
                            return Entry(
                                title: element["title"] as! String,
                                link: element["link"] as! String,
                                clickTrackingLink: element["clickTrackingLink"] as! String,
                                author: element["author"] as! String,
                                publishedDateJS: element["publishedDateJS"] as! String,
                                picture: element["picture"] as? String,
                                originalPicture: element["originalPicture"] as? String,
                                shortDescription: element["shortDescription"] as? String,
                                originalURL: element["originalURL"] as! String,
                                mobileLink: element["mobileLink"] as? String,
                                originalMobileUrl: element["originalMobileUrl"] as?    String,
                                shareURL: element["shareURL"] as! String,
                                mobileShareURL: element["mobileShareURL"] as? String,
                                ampURL: element["ampURL"] as? String,
                                articleID: parseArticleID(id: element["articleID"] as Any),
                                sectionID: element["sectionID"] as! Int,
                                sourceID: element["sourceID"] as! Int,
                                highlight: element["highlight"] as! Bool,
                                highlightType: element["highlightType"] as! String,
                                timeSince: "Juuri nyt",
                                orderNro: 0
                            )
                    }
                    
                    #if DEBUG
                        print("entries: \(entries.count)")
                    #endif
                    
                    return completionHandler(entries)

                case .failure(let error):
                    #if DEBUG
                        print("Error: \(#function)\n", error)
                    #endif
                    failureHandler(error.localizedDescription)
                    return
            }
        }
    }
	
	// make a silent HTTP GET request to the click tracking URL provided in the JSON's link field
    class func trackNewsClick(_ link: String) {
        #if DEBUG
            print("HighFiApi.trackNewsClick(\(link))")
        #endif
        let settings = Settings.sharedInstance
		
		DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
			Alamofire.request(link, parameters: ["APIKEY": settings.APIKEY, "appID": settings.appID])
	            .response { response in
    	            #if DEBUG
        	            print("trackNewsClick, request: \(String(describing: response.request))")
            	        // print("trackNewsClick, response: \(response)")
                	    // print("trackNewsClick, error: \(error)")
                	#endif
	        }
		}
    }
	
	// e.g. https://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
    class func getCategories(_ completionHandler: @escaping ([Category]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("HighFiApi.getCategories()")
        #endif
        
        let settings = Settings.sharedInstance
        setupManager(settings.appID, maxAge: 84600)

        let url = "https://" + settings.domainToUse + "/api/"
        
        let request = Alamofire.request(url, method: .get, parameters: ["act": settings.highFiActCategory, "usedLanguage": settings.useToRetrieveLists, "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
			
			#if DEBUG
				debugPrint(response)
			#endif
			
            switch response.result {
                case .success:
                    guard let json = response.result.value as? [String: AnyObject] else {
                        #if DEBUG
                            print("Error: \(#function)\n", "Did not get JSON array in response")
                        #endif
                        
                        failureHandler("Did not get JSON array in response")
                        return
                    }
                    
                    let responseData = json["responseData"] as! NSDictionary
                    
                    // Add always found categories to the list
                    var cat = [Category]()
                    cat.append(Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart, highlight: false, selected: true))
                    cat.append(Category(title: settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top", highlight: false, selected: true))
                    
                    let categories: [Category] = (responseData.value(forKey: "categories") as! [NSDictionary])
                        //                  .filter({ ($0["depth"] as! Int) == 1 })
                        .map {(element) in
                            return Category(
                                title: element["title"] as! String,
                                sectionID: element["sectionID"] as! Int,
                                depth: element["depth"] as! Int,
                                htmlFilename: element["htmlFilename"] as! String,
                                highlight: element["highlight"] as! Bool,
                                selected: false
                            )
                    }
                    
                    #if DEBUG
                        print("categories: \(categories.count)")
                    #endif
                    
                    return completionHandler(cat + categories)
            
                case .failure(let error):
                    #if DEBUG
                        print("Error: \(#function)\n", error)
                    #endif
                    failureHandler(error.localizedDescription)
                    return
            }
        }
    }

    // You should cache this method's return value for min 24h
    // https://high.fi/api/?act=listLanguages&APIKEY=123
    class func listLanguages(_ completionHandler: @escaping ([Language]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("HighFiApi.listLanguages()")
        #endif
    
        let settings = Settings.sharedInstance
    	setupManager(settings.appID, maxAge: 84600)
	
        let url = "https://" + settings.domainToUse + "/api"
        
        let request = Alamofire.request(url, method: .get, parameters: ["act":"listLanguages", "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
		
			#if DEBUG
				debugPrint(response)
			#endif
            
            switch response.result {
                case .success:
                    guard let json = response.result.value as? [String: AnyObject] else {
                        #if DEBUG
                            print("Error: \(#function)\n", "Did not get JSON array in response")
                        #endif
                        
                        failureHandler("Did not get JSON array in response")
                        return
                    }
                    
                    let responseData = json["responseData"] as! NSDictionary
                    
                    let languages: [Language] = (responseData.value(forKey: "supportedLanguages") as! [NSDictionary])
                        .map {(element) in
                            return Language(
                                language: element["language"] as! String,
                                country: element["country"] as! String,
                                domainToUse: element["domainToUse"] as! String,
                                languageCode: element["languageCode"] as! String,
                                mostPopularName: element["mostPopularName"] as! String,
                                latestName: element["latestName"] as! String,
                                useToRetrieveLists: element["useToRetrieveLists"] as!    String,
                                genericNewsURLPart: element["genericNewsURLPart"] as! String
                            )
                    }
                    
                    #if DEBUG
                        print("HighFiApi, languages: \(languages.count)")
                        //println("languages: \(languages)")
                    #endif
                    
                    return completionHandler(languages)
            
                case .failure(let error):
                    #if DEBUG
                        print("Error: \(#function)\n", error)
                    #endif
                    failureHandler(error.localizedDescription)
                    return
            }
        }
    }
	
    // https://high.fi/api/?act=listSources&usedLanguage=Finnish&APIKEY=123
    class func listSources(_ completionHandler: @escaping ([NewsSources]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("listSources()")
        #endif
    
        let settings = Settings.sharedInstance
    	setupManager(settings.appID, maxAge: 84600)
        
        let url = "https://" + settings.domainToUse + "/api"
        
        let request = Alamofire.request(url, method: .get, parameters: ["includePaid": settings.includePaid, "act": "listSources", "usedLanguage": settings.useToRetrieveLists, "APIKEY":settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
			#if DEBUG
				debugPrint(response)
			#endif
				
            switch response.result {
                case .success:
                    // make sure we got JSON and it's an array of dictionaries
                    guard let json = response.result.value as? [String: AnyObject] else {
                        #if DEBUG
                            print("Error: \(#function)\n", response.result.error!)
                        #endif
                        
                        failureHandler("Did not get JSON array in response")
                        return
                    }
                    
                    let responseData = json["responseData"] as! NSDictionary
                    let newsSources: [NewsSources] = (responseData.value(forKey: "newsSources") as! [NSDictionary])
                        .map {(element) in
                            return NewsSources(
                                sourceName: element["sourceName"] as! String,
                                sourceID: element["sourceID"] as! Int,
                                paywall: element["paywall"] as! String,
                                selected: false
                            )
                    }
                    
                    #if DEBUG
                        print("HighFiApi, newsSources: \(newsSources.count)")
                    #endif
                    
                    return completionHandler(newsSources)

                case .failure(let error):
                    #if DEBUG
                        print("Error: \(#function)\n", error)
                    #endif
                    failureHandler(error.localizedDescription)
                    return
            }
        }
    }
}
