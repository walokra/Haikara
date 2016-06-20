//
//  TodayViewController.swift
//  NewsWidget
//
//  Created by Marko Wallin on 20.6.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit
import NotificationCenter
import highkara

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NCWidgetProviding {
	
	struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCell = "tableCell"
        }
    }
	
	var entries = [Entry]()
	// default section
	var highFiSection: String = "uutiset"
	var page: Int = 1
	
	let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
	var loading = false
	
	let textColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1)
	var selectedCellBackground = UIView()
	let tintColor = UIColor(red: 171.0/255.0, green: 97.0/255.0, blue: 23.0/255.0, alpha: 1.0)
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		
		loadingIndicator.color = tintColor
   		loadingIndicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
   		loadingIndicator.center = self.view.center
   		self.view.addSubview(loadingIndicator)
   		loadingIndicator.bringSubviewToFront(self.view)
		
		if self.entries.isEmpty {
            getNews(self.page)
        }
		
		self.tableView!.delegate = self
		self.tableView!.dataSource = self
		
		selectedCellBackground.backgroundColor = UIColor.darkGrayColor()
		
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		self.tableView.tableFooterView?.hidden = true
		
		configureTableView()
    }
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 50.0
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
	
	func getNews(page: Int) {
		if (!self.loading) {
			self.setLoadingState(true)
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: highFiSection,
				completionHandler:{ (result) in
					let entries = Array(result[0..<5])
					self.setNews(entries)
				}
				, failureHandler: {(error)in
					self.handleError(error)
				}
			)
		}
	}
	
	func setNews(newsentries: Array<Entry>) {
		dispatch_async(dispatch_get_main_queue()) {
			// Clear old entries
			self.entries = [Entry]()
			self.entries =  newsentries
				
			self.tableView!.reloadData()
			self.setLoadingState(false)
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.entries.count
    }
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
//		HighFiApi.trackNewsClick(entry.clickTrackingLink)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

		dispatch_async(dispatch_get_main_queue(),{
//            let defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Highkara.Widget")!
            //self.labelWidget.text = defaults.objectForKey("AAPLvalue") as NSString
        });
		
        completionHandler(NCUpdateResult.NewData)
    }

}
