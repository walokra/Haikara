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
	
	let settings = Settings.sharedInstance
	
	// Variables
	var entries = [Entry]()
	let page: Int = 1
	let maxNewsItems: Int = 5

	// Loading indicator
	let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
	var loading = false
	
	// Theme colors
	let textColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
	var selectedCellBackground = UIView()
	let tintColor = UIColor(red: 171.0/255.0, green: 97.0/255.0, blue: 23.0/255.0, alpha: 1.0)
	
	// localization
	let errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	
	override func awakeFromNib() {
  	  super.awakeFromNib()
  	  resetContentSize()
  	}
	
  	override func viewDidAppear(animated: Bool) {
  	  super.viewDidAppear(animated)
  	  resetContentSize()
  	}
	
    override func viewDidLoad() {
		#if DEBUG
			print("viewDidLoad()")
		#endif
        super.viewDidLoad()
		
		setTheme()
		
		setLoadingIndicator()
		
		initView()
    }
	
	func setTheme() {
		selectedCellBackground.backgroundColor = UIColor.darkGrayColor()
	}
	
	func setLoadingIndicator() {
		loadingIndicator.color = tintColor
		loadingIndicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
		loadingIndicator.center = self.view.center
		self.view.addSubview(loadingIndicator)
		loadingIndicator.bringSubviewToFront(self.view)
	}
	
	func initView() {
		#if DEBUG
			print("initView()")
		#endif
		
		configureTableView()
		
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		self.tableView.tableFooterView?.hidden = true
		
//		if self.entries.isEmpty {
//            getNews(self.page)
//		}
	}
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 28.0
	}
	
	func handleError(error: String) {
		#if DEBUG
			print("handleError, error: \(error)")
		#endif
		
		self.setLoadingState(false)
		let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
		let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
		alertController.addAction(OKAction)
		
		self.presentViewController(alertController, animated: true){}
	}
	
	func getNews(page: Int) -> NCUpdateResult {
		if (!self.loading) {
			self.setLoadingState(true)
			var entries = Array<Entry>()
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: settings.genericNewsURLPart,
				completionHandler: { (result) in
					entries = Array(result[0..<self.maxNewsItems])
					
					self.entries = entries
		
					self.tableView.reloadData()
					self.resetContentSize()
					self.setLoadingState(false)
				}
				, failureHandler: {(error)in
					self.handleError(error)
				}
			)
		}
		
		return .NewData
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let path = self.tableView!.indexPathForSelectedRow!
		let row = path.row
		
		let tableItem = self.entries[row]
		
		var webURLString = tableItem.originalURL
		if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.settings.useMobileUrl) {
			webURLString = tableItem.originalMobileUrl!
		}		
		#if DEBUG
			print("didSelectRowAtIndexPath, webURL=\(webURLString)")
		#endif

		let url: NSURL = NSURL(string: "Highkara://com.ruleoftech/article?url=\(webURLString)")!
		self.extensionContext?.openURL(url, completionHandler: nil)

		self.trackNewsClick(tableItem)
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.entries.count
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
		let cell: TodayEntryCell! = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listCell, forIndexPath: indexPath) as? TodayEntryCell

        let tableItem: Entry = entries[indexPath.row] as Entry
        cell.entryTitle.text = tableItem.title
		cell.entryTitle.textColor = textColor
		
		cell.selectedBackgroundView = selectedCellBackground
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }
	
	func setLoadingState(loading: Bool) {
		self.loading = loading
		self.loadingIndicator.hidden = !loading
		if (loading) {
			self.loadingIndicator.startAnimating()
		} else {
			self.loadingIndicator.stopAnimating()
			self.loadingIndicator.hidesWhenStopped = true
		}
	}

	func trackNewsClick(entry: Entry) {
		HighFiApi.trackNewsClick(entry.clickTrackingLink)
	}
	
	func resetContentSize(){
		self.preferredContentSize = tableView.contentSize
	}
	
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
		#if DEBUG
			print("widgetPerformUpdateWithCompletionHandler")
		#endif
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

		dispatch_async(dispatch_get_main_queue(),{
			self.getNews(self.page)
			#if DEBUG
				print("widgetPerformUpdateWithCompletionHandler, results=\(self.entries.count)")
			#endif
			self.tableView.reloadData()
			self.resetContentSize()
			self.setLoadingState(false)

			completionHandler(NCUpdateResult.NewData)
        });
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
