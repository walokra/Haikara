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
	// default section
	var highFiSection: String = "uutiset"
	var page: Int = 1
	
	// Loading indicator
	let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
	var loading = false
	
	// Theme colors
	let textColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
	var selectedCellBackground = UIView()
	let tintColor = UIColor(red: 171.0/255.0, green: 97.0/255.0, blue: 23.0/255.0, alpha: 1.0)
	
//	@IBOutlet weak var tableView: UITableView!
	
	override func awakeFromNib() {
  	  super.awakeFromNib()
  	  resetContentSize()
  	}
  
  	override func viewDidAppear(animated: Bool) {
  	  super.viewDidAppear(animated)
  	  resetContentSize()
  	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		loadingIndicator.color = tintColor
   		loadingIndicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
   		loadingIndicator.center = self.view.center
   		self.view.addSubview(loadingIndicator)
   		loadingIndicator.bringSubviewToFront(self.view)
		
//		self.tableView!.delegate = self
//		self.tableView!.dataSource = self

		if self.entries.isEmpty {
            getNews(self.page)
        }
		
		selectedCellBackground.backgroundColor = UIColor.darkGrayColor()
		
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		self.tableView.tableFooterView?.hidden = true
		
		configureTableView()
    }
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 30.0
	}
	
	func handleError(error: String) {
		#if DEBUG
			print("handleError, error: \(error)")
		#endif
		
		self.setLoadingState(false)
		
//		let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
//		let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
//		alertController.addAction(OKAction)
		
//		self.presentViewController(alertController, animated: true){}
	}
	
	func getNews(page: Int) -> NCUpdateResult {
//		if (!self.loading) {
			self.setLoadingState(true)
			var entries = Array<Entry>()
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: highFiSection,
				completionHandler:{ (result) in
					print("getNews, result=\(result.count)")
					entries = Array(result[0..<5])
					
					self.entries = entries
		
					self.tableView.reloadData()
					self.resetContentSize()
					self.setLoadingState(false)
				}
				, failureHandler: {(error)in
					self.handleError(error)
				}
			)
//		}
		
		return .NewData
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let path = self.tableView!.indexPathForSelectedRow!
		let row = path.row
		
		let tableItem = self.entries[row]
		
		var webURL = NSURL(string: tableItem.originalURL)
		if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.settings.useMobileUrl) {
			webURL = NSURL(string: tableItem.originalMobileUrl!)
		}		
		#if DEBUG
			print("didSelectRowAtIndexPath, useMobileUrl=\(self.settings.useMobileUrl), useReaderView=\(self.settings.useReaderView)")
			print("didSelectRowAtIndexPath, webURL=\(webURL)")
		#endif
		
//		let svc = SFSafariViewController(URL: webURL!, entersReaderIfAvailable: settings.useReaderView)
//		svc.view.tintColor = tintColor
//		self.presentViewController(svc, animated: true, completion: nil)

		let url: NSURL = NSURL(string: "Highkara://\(webURL)")!
		self.extensionContext?.openURL(url, completionHandler: nil)

		// Safari
		//self.extensionContext?.openURL(webURL!, completionHandler: nil)

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
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func resetContentSize(){
		self.preferredContentSize = tableView.contentSize
  	}
	
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

		dispatch_async(dispatch_get_main_queue(),{
//            let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Highkara.Widget")!
            //self.labelWidget.text = defaults.objectForKey("AAPLvalue") as NSString
			
			let result = self.getNews(self.page)
			if result == .NewData {
				#if DEBUG
					print("widgetPerformUpdateWithCompletionHandler, .NewData. results=\(self.entries.count)")
				#endif
				self.tableView.reloadData()
				self.resetContentSize()
				self.setLoadingState(false)
			
				completionHandler(result)
			}
        });
    }

}
