//
//  HighFiApi.swift
//  Haikara
//
//  Created by Marko Wallin on 29.8.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
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
    	// http://high.fi/search.cfm?q=formula&x=0&y=0&outputtype=json-private
    	let settings = Settings.sharedInstance
		setupManager(settings.appID, maxAge: 60)

        let feed = "http://" + settings.domainToUse + "/search.cfm"
		
		let request = Alamofire.request(feed, method: .get, parameters: ["q": searchText, "x": 0, "y": 0, "outputtype": settings.highFiEndpoint, "APIKEY": settings.APIKEY])

            request.validate()
            request.responseJSON{ response in
			
			#if DEBUG
				debugPrint(response)
			#endif
				
			// check if responseJSON already has an error
			// e.g., no network connection
  			guard response.result.error == nil else {
				#if DEBUG
                    print("Error: \(#function)\n", response.result.error!)
                #endif
				failureHandler(response.result.error! as! String)
    			return
  			}
			
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
                        ampURL: $0["ampURL"] as? String,
                        articleID: $0["articleID"] as! Int,
                        sectionID: $0["sectionID"] as! Int,
                        sourceID: $0["sourceID"] as! Int,
                        highlight: $0["highlight"] as! Bool,
						highlightType: $0["highlightType"] as! String,
                        timeSince: "Juuri nyt",
						orderNro: 0
                        )
                }
                #if DEBUG
                    print("entries: \(entries.count)")
                #endif
			
			return completionHandler(entries)
        }
	}

    // Getting news from High.fi and return values to blocks as completion handlers, completion closure (callback)
	// e.g. http://high.fi/uutiset/json-private
    class func getNews(_ page: Int, section: String, completionHandler: @escaping ([Entry]) -> Void, failureHandler: @escaping (String) -> Void) {
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
		
        let request = Alamofire.request(feed, method: .get, parameters: ["APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID, "jsonHideSections": categoriesHiddenParam])

            request.validate()
            request.responseJSON{ response in
				
			#if DEBUG
				debugPrint(response)
			#endif
				
			// check if responseJSON already has an error
			// e.g., no network connection
  			guard response.result.error == nil else {
				#if DEBUG
                    print("Error: \(#function)\n", response.result.error!)
                #endif
				failureHandler(response.result.error! as! String)
    			return
  			}
			
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
                        ampURL: $0["ampURL"] as? String,
                        articleID: $0["articleID"] as! Int,
                        sectionID: $0["sectionID"] as! Int,
                        sourceID: $0["sourceID"] as! Int,
                        highlight: $0["highlight"] as! Bool,
						highlightType: $0["highlightType"] as! String,
                        timeSince: "Juuri nyt",
						orderNro: 0
                        )
                }

            #if DEBUG
                print("entries: \(entries.count)")
            #endif
			
			return completionHandler(entries)
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
	
	// e.g. http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
    class func getCategories(_ completionHandler: @escaping ([Category]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("HighFiApi.getCategories()")
        #endif
        
        let settings = Settings.sharedInstance
        setupManager(settings.appID, maxAge: 84600)

        let url = "http://" + settings.domainToUse + "/api/"
        
        let request = Alamofire.request(url, method: .get, parameters: ["act": settings.highFiActCategory, "usedLanguage": settings.useToRetrieveLists, "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
			
			#if DEBUG
				debugPrint(response)
			#endif
				
			// check if responseJSON already has an error
			// e.g., no network connection
  			guard response.result.error == nil else {
				#if DEBUG
                    print("Error: \(#function)\n", response.result.error!)
                #endif
				failureHandler(response.result.error! as! String)
    			return
  			}
			
			// make sure we got JSON and it's an array of dictionaries
//			guard let json = response.result.value as? [String: AnyObject] else {
//                #if DEBUG
//                    print("Error: \(#function)\n", response.result.error!)
//                #endif
//
//        		failureHandler("Did not get JSON array in response")
//        		return
//      		}

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
//          	    .filter({ ($0["depth"] as! Int) == 1 })
				.map { Category(
					title: $0["title"] as! String,
					sectionID: $0["sectionID"] as! Int,
					depth: $0["depth"] as! Int,
					htmlFilename: $0["htmlFilename"] as! String,
					highlight: $0["highlight"] as! Bool,
					selected: false
					)
			}

            #if DEBUG
                print("categories: \(categories.count)")
            #endif
			
			return completionHandler(cat + categories)
        }
    }

    // You should cache this method's return value for min 24h
    // http://high.fi/api/?act=listLanguages&APIKEY=123
    class func listLanguages(_ completionHandler: @escaping ([Language]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("HighFiApi.listLanguages()")
        #endif
    
        let settings = Settings.sharedInstance
    	setupManager(settings.appID, maxAge: 84600)
	
        let url = "http://" + settings.domainToUse + "/api"
        
        let request = Alamofire.request(url, method: .get, parameters: ["act":"listLanguages", "APIKEY": settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
		
			#if DEBUG
				debugPrint(response)
			#endif
				
			// check if responseJSON already has an error
			// e.g., no network connection
  			guard response.result.error == nil else {
				#if DEBUG
                    print("Error: \(#function)\n", response.result.error!)
                #endif
				failureHandler(response.result.error! as! String)
    			return
  			}

			guard let json = response.result.value as? [String: AnyObject] else {
                #if DEBUG
                    print("Error: \(#function)\n", "Did not get JSON array in response")
                #endif

        		failureHandler("Did not get JSON array in response")
        		return
      		}
			
			let responseData = json["responseData"] as! NSDictionary

            let languages: [Language] = (responseData.value(forKey: "supportedLanguages") as! [NSDictionary])
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
        }
    }
	
    // http://high.fi/api/?act=listSources&usedLanguage=Finnish&APIKEY=123
    class func listSources(_ completionHandler: @escaping ([NewsSources]) -> Void, failureHandler: @escaping (String) -> Void) {
        #if DEBUG
            print("listSources()")
        #endif
    
        let settings = Settings.sharedInstance
    	setupManager(settings.appID, maxAge: 84600)
        
        let url = "http://" + settings.domainToUse + "/api"
        
        let request = Alamofire.request(url, method: .get, parameters: ["act":"listSources", "usedLanguage":settings.useToRetrieveLists, "APIKEY":settings.APIKEY, "deviceID": settings.deviceID, "appID": settings.appID])
        request.validate()
        request.responseJSON { response in
			#if DEBUG
				debugPrint(response)
			#endif
				
			// check if responseJSON already has an error
			// e.g., no network connection
  			guard response.result.error == nil else {
				#if DEBUG
                    print("Error: \(#function)\n", response.result.error!)
                #endif
				failureHandler(response.result.error! as! String)
    			return
  			}
			
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
        }
    }
}
