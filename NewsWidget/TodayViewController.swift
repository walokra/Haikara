//
//  TodayViewController.swift
//  NewsWidget
//
//  Created by Marko Wallin on 20.6.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UITableViewController, NCWidgetProviding {

	struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCell = "tableCell"
        }
    }
	
	let defaults: UserDefaults = UserDefaults.init(suiteName: "VZSFR9BSV5.group.com.ruleoftech.highkara")!
	
	let defaultValues = Defaults(
			useToRetrieveLists: "finnish",
			mostPopularName: "Suosituimmat",
			latestName: "Uusimmat",
			domainToUse: "fi.high.fi",
			genericNewsURLPart: "uutiset",
			showDesc: false,
			useMobileUrl: true,
			useReaderView: false,
			useDarkTheme: false,
			showNewsPicture: false,
			useChrome: false,
			createNewTab: false,
			region: "Finland",
			optOutAnalytics: false,
			fontName: "Avenir-Light",
			useSystemSize: true,
			fontSizeBase: 10.0
		)
	
	var region: String? // http://high.fi/api/?act=listLanguages
	var genericNewsURLPart: String?
	var useMobileUrl: Bool? // Prefer mobile optimized URLs
	var todayCategoryByLang = Dictionary<String, Category>()
	
    func initSettings() {
        #if DEBUG
            print(#function)
        #endif
		
		if let region: String = defaults.object(forKey: "region") as? String {
            self.region = region
        } else {
            self.region = defaultValues.region
        }
		
        if let useMobileUrl: Bool = defaults.object(forKey: "useMobileUrl") as? Bool {
            self.useMobileUrl = useMobileUrl
        } else {
            self.useMobileUrl = defaultValues.useMobileUrl
        }
		
		// Get Dictionary of today categories from storage
		NSKeyedUnarchiver.setClass(Category.self, forClassName: "highkara.Category")
		NSKeyedUnarchiver.setClass(Language.self, forClassName: "highkara.Language")
		NSKeyedUnarchiver.setClass(NewsSources.self, forClassName: "highkara.NewsSources")
        if let unarchivedtodayCategoryByLang = defaults.object(forKey: "todayCategoryByLang") as? Data {
            self.todayCategoryByLang = NSKeyedUnarchiver.unarchiveObject(with: unarchivedtodayCategoryByLang) as! Dictionary<String, Category>
			self.selectedTodayCategoryName = self.todayCategoryByLang[self.region!]!.htmlFilename
		} else {
			if let genericNewsURLPart: String = defaults.object(forKey: "genericNewsURLPart") as? String {
            	self.selectedTodayCategoryName = genericNewsURLPart
        	} else {
            	self.selectedTodayCategoryName = defaultValues.genericNewsURLPart
        	}
		}
    }
	
	// Variables
	var entries = [Entry]()
	var newsEntriesUpdatedByLang = Dictionary<String, Date>()
	let page: Int = 1
	let maxNewsItems: Int = 5
	var selectedTodayCategoryName: String?

	// Loading indicator
	let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
	var loading = false
	
	// Theme colors
	let textColorLight = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
	let textColorDark = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
	var selectedCellBackground = UIView()
	let tintColor = UIColor(red: 171.0/255.0, green: 97.0/255.0, blue: 23.0/255.0, alpha: 1.0)
	
	// localization
	let errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	
    override func viewDidLoad() {
		#if DEBUG
			print("viewDidLoad()")
		#endif
        super.viewDidLoad()

        if #available(iOSApplicationExtension 10.0, *) {
            self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
            resetContentSize()
        } else {
            // Fallback on earlier versions
        }

		initSettings()
		setTheme()
		
		setLoadingIndicator()
		
		initView()
    }
	
	func setTheme() {
		selectedCellBackground.backgroundColor = UIColor.darkGray
	}
	
	func setLoadingIndicator() {
		loadingIndicator.color = tintColor
		loadingIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
		loadingIndicator.center = self.view.center
		self.view.addSubview(loadingIndicator)
		loadingIndicator.bringSubview(toFront: self.view)
	}
	
	func initView() {
		#if DEBUG
			print("initView()")
		#endif
		
		setTodayCategory()
		
		configureTableView()
		
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		self.tableView.tableFooterView?.isHidden = true
		
		if self.entries.isEmpty {
            _ = getNews(self.page)
		}
	}
	
	func setTodayCategory() {
		#if DEBUG
			print("TodayViewController, setTodayCategory: getting today category for '\(String(describing: self.region))' from settings")
		#endif
		
		if let category: Category = self.todayCategoryByLang[self.region!] {
			#if DEBUG
				print("TodayViewController, setTodayCategory: \(category)")
			#endif
			
			self.selectedTodayCategoryName = category.htmlFilename
		}
	}

    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            self.preferredContentSize = maxSize;
        }
        else {
            self.preferredContentSize = tableView.contentSize
        }
    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsets.zero
    }
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 33.0
	}
	
	func getNews(_ page: Int) -> NCUpdateResult {
		if (!self.loading) {
			if !self.entries.isEmpty {
            	#if DEBUG
            	    print("TodayViewController, getNews: checking if entries need refreshing")
            	#endif
            
            	if let updated: Date = self.newsEntriesUpdatedByLang[self.region!] {
            	    let calendar = Calendar.current
            	    var comps = DateComponents()
            	    comps.minute = 1
            	    let updatedPlusMinute = (calendar as NSCalendar).date(byAdding: comps, to: updated, options: NSCalendar.Options())
            	    let today = Date()
                
            	    #if DEBUG
            	        print("TodayViewController, getNews: today=\(today), updated=\(updated), updatedPlusMinute=\(String(describing: updatedPlusMinute))")
            	    #endif
					
            	    if updatedPlusMinute!.isGreaterThanDate(today) {
						#if DEBUG
            	        	print("TodayViewController, getNews: No need for updating entries")
            	    	#endif
            	        return .noData
            	    }
            	}
        	}
			
			self.setLoadingState(true)
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: self.selectedTodayCategoryName!,
				completionHandler: { (result) in
					self.entries = Array(result[0..<self.maxNewsItems])
		
					self.tableView.reloadData()
					self.resetContentSize()
					self.setLoadingState(false)
				}
				, failureHandler: {(error)in
					self.handleError(error, title: self.errorTitle)
				}
			)
		}
		
		return .newData
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let path = self.tableView!.indexPathForSelectedRow!
		let row = path.row
		
		let tableItem = self.entries[row]
		
		var webURLString = tableItem.originalURL
		if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.useMobileUrl!) {
			webURLString = tableItem.originalMobileUrl!
		}		
		#if DEBUG
			print("didSelectRowAtIndexPath, webURL=\(webURLString)")
		#endif

		let url: URL = URL(string: "Highkara://article?url=\(webURLString)")!
		self.extensionContext?.open(url, completionHandler: nil)

		self.trackNewsClick(tableItem)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.entries.count
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
		let cell: TodayEntryCell! = tableView.dequeueReusableCell(withIdentifier: MainStoryboard.TableViewCellIdentifiers.listCell, for: indexPath) as? TodayEntryCell

        let tableItem: Entry = entries[indexPath.row] as Entry
        cell.entryTitle.text = tableItem.title
		// In iOS 19 widget background is light grey
		if #available(iOS 10.0, *) {
			cell.entryTitle.textColor = textColorDark
		} else {
			cell.entryTitle.textColor = textColorLight
		}
		
		cell.selectedBackgroundView = selectedCellBackground
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }
	
	func setLoadingState(_ loading: Bool) {
		self.loading = loading
		self.loadingIndicator.isHidden = !loading
		if (loading) {
			self.loadingIndicator.startAnimating()
		} else {
			self.loadingIndicator.stopAnimating()
			self.loadingIndicator.hidesWhenStopped = true
		}
	}

	func trackNewsClick(_ entry: Entry) {
		HighFiApi.trackNewsClick(entry.clickTrackingLink)
	}
	
	func resetContentSize(){
		self.preferredContentSize = tableView.contentSize
	}
	
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		#if DEBUG
			print("widgetPerformUpdateWithCompletionHandler")
		#endif
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

		DispatchQueue.main.async(execute: {
			_ = self.getNews(self.page)
			#if DEBUG
				print("widgetPerformUpdateWithCompletionHandler, results=\(self.entries.count)")
			#endif
			self.tableView.reloadData()
			self.resetContentSize()
			self.setLoadingState(false)

			completionHandler(NCUpdateResult.newData)
        });
		
		completionHandler(NCUpdateResult.noData)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
//	// stop observing
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
}
