//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

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
	
	var navigationItemTitle: String = NSLocalizedString("MAIN_TITLE", comment: "Title for main view")

	@IBOutlet weak var tableView: UITableView!

	var refreshControl:UIRefreshControl!

	let calendar = NSCalendar.autoupdatingCurrentCalendar()
	let dateFormatter = NSDateFormatter()
	
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	var loading = false
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = navigationItemTitle
		
		self.tableView!.delegate=self
		self.tableView!.dataSource = self
		
		configureTableView()
		
		dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"

//		self.tableFooter.hidden = true
		
		self.page = 1
		getNews(self.page)
				
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("REFRESH", comment: "Refresh the news"))
		self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)
    }
	
	func getNews(page: Int) {
		if (!self.loading) {
			self.setLoadingState(true)
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: highFiSection) {
				(result: Array<Entry>) in
				self.setNews(result)
			}
		}
	}
	
	func setNews(newsentries: Array<Entry>) {
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
				var entry = item as! Entry
				//							println("section=\(entry.section), title=\(entry.title)")
				if self.sections[entry.timeSince] == nil {
					self.sections[entry.timeSince] = [entry]
				} else {
					self.sections[entry.timeSince]!.append(entry)
				}
				
				// Storing sections in dictionary, so we need to sort it
				self.sortedSections = self.sections.keys //.array.sorted(<)
			}
			//println("sections=\(self.sections.count)")
			
			self.tableView!.reloadData()
			self.refreshControl?.endRefreshing()
			self.setLoadingState(false)
			self.scrollToTop()
			
			return
		}
	}
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75.0
	}
	
	func refresh(sender:AnyObject) {
//		println("refresh: \(sender)")
		self.page = 1
		getNews(self.page)
	}
	
	// MARK: - Navigation

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.

		if segue.identifier == "NewsItemDetails" {
			let path = self.tableView!.indexPathForSelectedRow()!
			let row = path.row
			
			let tableSection = sections[sortedSections[path.section]]
			let tableItem = tableSection![row]
			
			println("mobileLink= \(tableItem.mobileLink), link= \(tableItem.link)")
			(segue.destinationViewController as! NewsItemViewController).title = tableItem.title
			if (tableItem.mobileLink?.isEmpty != nil && settings.useMobileUrl) {
				(segue.destinationViewController as! NewsItemViewController).webSite = tableItem.originalURL
			} else {
				(segue.destinationViewController as! NewsItemViewController).webSite = tableItem.mobileLink
			}
			
			// make a silent HTTP GET request to the click tracking URL provided in the JSON's link field
			HighFiApi.trackNewsClick(tableItem.link)
		}
	}

    // MARK: - Table view data source

	// Change the color of the section bg and font
	func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		
		// This changes the header background
		view.tintColor = UIColor.lightGrayColor()
	
		// UIColor(red: 254.0/255.0, green: 190.0/255.0, blue: 127.0/255.0, alpha: 1)
		
		// Gets the header view as a UITableViewHeaderFooterView and changes the text colour
		var headerView: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
		headerView.textLabel.textColor = UIColor.blackColor()
		
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
//		println("tableItem=\(tableItem)")
		cell.entryTitle.text = tableItem.title
		cell.entryAuthor.text = tableItem.author
		if tableItem.shortDescription != "" && settings.showDesc {
			cell.entryDescription!.text = tableItem.shortDescription
		}
		if tableItem.highlight == true {
			cell.highlighted = true
		}
		
		return cell
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sortedSections[section]
	}
	
	func scrollToTop() {
		if (self.numberOfSectionsInTableView(self.tableView) > 0 ) {
			var top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
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
	
	func setLoadingState(loading:Bool) {
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
			let components = calendar.components(
				NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: startDate, toDate: NSDate(), options: nil)
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
					if hours < 24 { return String(format: NSLocalizedString("< %d hours", comment: ""), hours) }
				}
			} else {
				if days == 1 {
					return NSLocalizedString("YESTERDAY", comment: "")
				} else {
					return String(format: NSLocalizedString("%d days", comment: ""), hours)
				}
			}
		}
		
		return NSLocalizedString("LONG_TIME", comment: "")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
