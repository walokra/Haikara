//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

import SafariServices

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "tableCell"
	var entries = NSMutableOrderedSet()
	let settings = Settings.sharedInstance
	let maxHeadlines: Int = 70
	var page: Int = 1
	
	var sections = OrderedDictionary<String, Array<Entry>>()
	var sortedSections = [String]()
	
	// default section
	var highFiSection: String = "uutiset"
	
	var navigationItemTitle: String = ""
	var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	var shareButtonText: String = NSLocalizedString("SHARE_BUTTON", comment: "Text for share button")

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var poweredLabel: UILabel!

	var refreshControl: UIRefreshControl!

	let calendar = NSCalendar.autoupdatingCurrentCalendar()
	let dateFormatter = NSDateFormatter()
	
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	var loading = false
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
		#if DEBUG
			print("viewDidLoad()")
		#endif
        super.viewDidLoad()

		setObservers()
		setTheme()
		
		navigationItemTitle = settings.latestName

		self.initView()
    }
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setTheme:", name: "themeChangedNotification", object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tableView.backgroundColor = Theme.backgroundColor
		self.poweredLabel.textColor = Theme.poweredLabelColor
		
		// TODO: How to update the bar after changing
		self.navigationController!.navigationBar.backgroundColor = Theme.backgroundColor;

	}
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("DetailViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	func initView() {
		#if DEBUG
			print("initView()")
		#endif
		self.navigationItem.title = navigationItemTitle
		
		self.tableView!.delegate=self
		self.tableView!.dataSource = self
		
		configureTableView()
		
		dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
		
		// self.tableFooter.hidden = true
		
		self.page = 1
		getNews(self.page)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("REFRESH", comment: "Refresh the news"))
		self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	func handleError(error: String) {
		#if DEBUG
			print("handleError, error: \(error)")
		#endif
		let alertController = UIAlertController(title: errorTitle, message: error, preferredStyle: .Alert)
		let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
		alertController.addAction(OKAction)
		
		self.presentViewController(alertController, animated: true){}
	}
	
	func getNews(page: Int) {
		if (!self.loading) {
			self.setLoadingState(true)
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: highFiSection,
				completionHandler:{ (result) in
					self.setNews(result)
				}
				, failureHandler: {(error)in
					self.handleError(error)
				}
			)
		}
	}
	
	func handleError(error: ErrorType) {
		
	}
	
	func setNews(newsentries: Array<Entry>) {
		// Top items are not grouped by time
		print("highFiSection=\(highFiSection)")
		if highFiSection == "top" {
			dispatch_async(dispatch_get_main_queue()) {
				// Clear old entries
				self.entries = NSMutableOrderedSet()
				self.sections = OrderedDictionary<String, Array<Entry>>()
				self.sortedSections = [String]()
				
				self.entries.addObjectsFromArray(newsentries)
				
				var i = 0
				var range = "1 ..10"
				for item in self.entries {
					let entry = item as! Entry
					if (i < 10) {
						range = "1 ..10"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else if (i < 20) {
						range = "11 ..20"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else if (i < 30) {
						range = "21 ..30"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else if (i < 40) {
						range = "31 ..40"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else if (i < 50) {
						range = "41 ..50"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else if (i < 60) {
						range = "51 ..60"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else if (i < 70) {
						range = "61 ..70"
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					} else {
						range = "70 ..."
						self.sections[range] == nil ? self.sections[range] = [entry] : self.sections[range]!.append(entry)
					}
					
					self.sortedSections = self.sections.keys
					i++
				}
				//println("sections=\(self.sections.count)")
				
				self.tableView!.reloadData()
				self.refreshControl?.endRefreshing()
				self.setLoadingState(false)
				self.scrollToTop()
				
				return
			}
		} else {
			// Other categories are grouped by time
			for item in newsentries {
				item.timeSince = self.getTimeSince(item.publishedDateJS)
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				// Clear old entries
				self.entries = NSMutableOrderedSet()
				self.sections = OrderedDictionary<String, Array<Entry>>()
				self.sortedSections = [String]()
				
				self.entries.addObjectsFromArray(newsentries)
				//println("newsEntries=\(self.newsEntries.count)")
				
				// Put each item in a section
				for item in self.entries {
					// If we don't have section for particular time, create new one,
					// Otherwise just add item to existing section
					let entry = item as! Entry
					//	println("section=\(entry.section), title=\(entry.title)")
					if self.sections[entry.timeSince] == nil {
						self.sections[entry.timeSince] = [entry]
					} else {
						self.sections[entry.timeSince]!.append(entry)
					}
					
					self.sortedSections = self.sections.keys
				}
				//println("sections=\(self.sections.count)")
				
				self.tableView!.reloadData()
				self.refreshControl?.endRefreshing()
				self.setLoadingState(false)
				self.scrollToTop()
				
				return
			}
		}
	}
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75.0
	}
	
	func refresh(sender:AnyObject) {
		self.page = 1
		getNews(self.page)
	}
	
	// MARK: - Navigation

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let path = self.tableView!.indexPathForSelectedRow!
		let row = path.row
		
		let tableSection = sections[sortedSections[path.section]]
		let tableItem = tableSection![row]
		
		let webURL = NSURL(string: tableItem.originalURL)
		let trackingLink = tableItem.clickTrackingLink
		#if DEBUG
			print("didSelectRowAtIndexPath, useMobileUrl=\(settings.useMobileUrl), useReaderView=\(settings.useReaderView)")
			print("didSelectRowAtIndexPath, webURL=\(webURL)")
			print("didSelectRowAtIndexPath, trackingLink=\(trackingLink)")
		#endif
		
		if #available(iOS 9.0, *) {
			#if DEBUG
				print("iOS 9.0, *")
			#endif
			let svc = SFSafariViewController(URL: webURL!, entersReaderIfAvailable: settings.useReaderView)
			svc.view.tintColor = Theme.tintColor
			self.presentViewController(svc, animated: true, completion: nil)
		} else {
			#if DEBUG
				print("Fallback on earlier versions")
			#endif
			let vc = NewsItemViewController()
			vc.title = tableItem.title
			vc.loadWebView(webURL!)
			self.navigationController?.pushViewController(vc, animated: true)
		}
		
		// make a silent HTTP GET request to the click tracking URL provided in the JSON's link field
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
			HighFiApi.trackNewsClick(trackingLink)
		}
	}
	
	// Dismiss the view controller and return to app.
	@available(iOS 9.0, *)
	func safariViewControllerDidFinish(controller: SFSafariViewController) {
		controller.dismissViewControllerAnimated(true, completion: nil)
	}
	
    // MARK: - Table view data source

	// Change the color of the section bg and font
	func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		
		// This changes the header background
		view.tintColor = Theme.sectionColor
		
		// Gets the header view as a UITableViewHeaderFooterView and changes the text colour
		let headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
		headerView.textLabel!.textColor = UIColor.blackColor()
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
		return self.sections.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
		return self.sections[sortedSections[section]]!.count
    }
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Configure the cell for this indexPath
		let cell: EntryCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? EntryCell

		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
		cell.entryTitle.text = tableItem.title
		cell.entryTitle.textColor = Theme.cellTitleColor
		cell.entryAuthor.text = tableItem.author
		cell.entryAuthor.textColor = Theme.cellAuthorColor
		if (tableItem.shortDescription != "" && settings.showDesc) {
			cell.entryDescription.text = tableItem.shortDescription
			cell.entryDescription.hidden = false
		} else {
			cell.entryDescription.text = ""
			cell.entryDescription.hidden = true
		}
		cell.entryDescription.textColor = Theme.cellDescriptionColor
		
		if tableItem.highlight == true {
			cell.highlighted = true
		}
		
		cell.selectedBackgroundView = Theme.selectedCellBackground
		
		if (indexPath.row % 2 == 0) {
			cell.backgroundColor = Theme.evenRowColor
		} else {
			cell.backgroundColor = Theme.oddRowColor
		}
				
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }
	
//	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: shareButtonText) {
			(action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
//			let cell: EntryCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? EntryCell
			
			let tableSection = self.sections[self.sortedSections[indexPath.section]]
			let tableItem = tableSection![indexPath.row]
			
			var webURL = tableItem.shareURL
			if (tableItem.mobileShareURL?.isEmpty != nil && self.settings.useMobileUrl) {
				webURL = tableItem.mobileShareURL!
			}
			
			let objectsToShare = [tableItem.title, webURL]
			let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			self.presentViewController(activityViewController, animated: true, completion: nil)
			
			// if iPad ?
//			if let popPresentationController : UIPopoverPresentationController = activityViewController.popoverPresentationController {
//					// If this happens you'll need to set the UIPopoverPresentationController properties of sourceView, sourceRect and permittedArrowDirections
//			}
		}
//		Background color gets tiled, not good
//		shareAction.backgroundColor = UIColor(patternImage: UIImage(named:"share")!)
		
		return [shareAction]
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sortedSections[section]
	}
	
	// Enable swiping for showing action buttons
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	// We need empty implementation to get editActionsForRowAtIndexPath to work.
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}
	
	func scrollToTop() {
		if (self.numberOfSectionsInTableView(self.tableView) > 0 ) {
			let top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
			self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
		}
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//		println("scrollViewDidScroll, maximumOffset=\(maximumOffset); currentOffset=\(currentOffset)")
		if (maximumOffset - currentOffset) <= -40 {
			if (!self.loading && self.entries.count == self.maxHeadlines && self.highFiSection != "top") {
				self.page += 1
				self.getNews(page)
			}
		}
	}
	
	func setLoadingState(loading: Bool) {
		self.loading = loading
		self.loadingIndicator.hidden = !loading
		if (loading) {
			self.loadingIndicator.startAnimating()
		} else {
			self.loadingIndicator.stopAnimating()
		}
	}
	
	func getTimeSince(item: String) -> String {
		//println("getTimeSince: \(item)")
		if let startDate = dateFormatter.dateFromString(item) {
			let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: startDate, toDate: NSDate(), options: [])
			let days = components.day
			let hours = components.hour
			let minutes = components.minute
//			println("\(days) days, \(hours) hours, \(minutes) minutes")
			
			if days == 0 {
				if hours == 0 {
					if minutes < 0 { return NSLocalizedString("JUST_NOW", comment: "") }
					else if minutes < 5 { return NSLocalizedString("5_MIN", comment: "") }
					else if minutes < 15 { return NSLocalizedString("15_MIN", comment: "") }
					else if minutes < 30 { return NSLocalizedString("30_MIN", comment: "") }
					else if minutes < 45 { return NSLocalizedString("45_MIN", comment: "") }
					else if minutes < 60 { return NSLocalizedString("HOUR", comment: "") }
				} else {
					if hours == 1 {
						return String(format: NSLocalizedString("< %d hours", comment: ""), hours+1)
					} else {
						return String(format: NSLocalizedString("< %d hours", comment: ""), hours)
					}
				}
			} else {
				if days == 1 {
					return NSLocalizedString("YESTERDAY", comment: "")
				} else {
					return String(format: NSLocalizedString("%d days", comment: ""), days)
				}
			}
		}
		
		return NSLocalizedString("LONG_TIME", comment: "")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension DetailViewController: CategorySelectionDelegate {
	func categorySelected(newCategory: Category) {
		self.page = 1
		self.navigationItem.title = newCategory.title
		self.highFiSection = newCategory.htmlFilename
		getNews(self.page)
	}
}
