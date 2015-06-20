//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

import Alamofire

//{
//	"responseData": {
//		"feed": {
//			"title": "HIGH.FI",
//			"link": "http://fi.high.fi/",
//			"author": "AfterDawn Oy",
//			"description": "News",
//			"type": "json",
//			"entries": [
//{
//	"title": "string",
//	"link": "url",
//	"author": "string",
//	"publishedDateJS": "2015-06-16T22:46:08.000Z",
//	"publishedDate": "June, 16 2015 22:46:08",
//	"originalPicture": "url",
//	"picture": "url",
//	"shortDescription": "",
//	"originalURL": "url",
//	"mobileLink": "",
//	"originalMobileURL": "",
//	"articleID": int,
//	"sectionID": int,
//	"sourceID": int,
//	"highlight": true
//	
//},

class NewsEntry: NSObject {
	let title: String
	let link: String
	let author: String
	let publishedDateJS: String
	//	let picture: String?
	//	let originalPicture: String?
	var shortDescription: String?
	//	let originalURL: String
	var mobileLink: String?
	//	let originalMobileUrl: String?
	//	let articleID: Int
	var sectionID: Int
	//	let sourceID: Int
	//	let highlight: Bool
	var section: String
	
	init(title: String, link: String, author: String, publishedDateJS: String,
		shortDescription: String?, mobileLink: String?, sectionID: Int, section: String) {
		self.title = title
		self.link = link
		self.author = author
		self.publishedDateJS = publishedDateJS
		//	let picture: String?
		//	let originalPicture: String?
		self.shortDescription = shortDescription
		//	letoriginalURL: String
		self.mobileLink = mobileLink
		//	let originalMobileUrl: String?
		//	let articleID: Int
		self.sectionID = sectionID
		//	let sourceID: Int
		//	let highlight: Bool
		self.section = section
	}
	
	override var description: String {
		return "newsEntry: title=\(self.title), link=\(self.link), author=\(self.author), published=\(self.publishedDateJS), desc=\(self.shortDescription), mobileLink=\(self.mobileLink), sectionID=\(self.sectionID), section=\(section)"
	}
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "tableCell"
	var newsEntries = NSMutableOrderedSet()
	
	var sections = Dictionary<String, Array<NewsEntry>>()
	var sortedSections = [String]()

	let APIKEY: String = ""
	let highFiEndpoint: String = "http://fi.high.fi/news/json-private"

	@IBOutlet weak var tableView: UITableView!

	var refreshControl:UIRefreshControl!

	// `UIKit` convenience class for sectioning a table
	let collation = UILocalizedIndexedCollation.currentCollation() as! UILocalizedIndexedCollation

	let calendar = NSCalendar.autoupdatingCurrentCalendar()
	let dateFormatter = NSDateFormatter()
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Uutiset";

		self.tableView!.dataSource = self
		
		// `UIKit` convenience class for sectioning a table
		let collation = UILocalizedIndexedCollation.currentCollation() as! UILocalizedIndexedCollation
		
		calendar.timeZone = NSTimeZone.systemTimeZone()
		dateFormatter.timeZone = calendar.timeZone
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"

        getHighFiJSON(highFiEndpoint)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: "Vedä alas päivittääksesi")
		self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
	
	func refresh(sender:AnyObject) {
		getHighFiJSON(highFiEndpoint)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "NewsItemDetails" {
			let path = self.tableView!.indexPathForSelectedRow()!
			let row = path.row
			
			let highfiEntry : NewsEntry = self.newsEntries.objectAtIndex(row) as! NewsEntry
//			println("mobileLink= \(highfiEntry.mobileLink)")
//			println("link= \(highfiEntry.link)")
			(segue.destinationViewController as! NewsItemViewController).title = highfiEntry.title
			if (highfiEntry.mobileLink?.isEmpty != nil) {
				(segue.destinationViewController as! NewsItemViewController).webSite = highfiEntry.link
			} else {
				(segue.destinationViewController as! NewsItemViewController).webSite = highfiEntry.mobileLink
			}
		}
	}

    // MARK: - Table view data source

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        //return 1
		return self.sections.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        //return self.newsEntries.count
		return sections[sortedSections[section]]!.count
    }
	
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
//		
//		// Configure the cell for this indexPath
//		cell.textLabel!.text = (newsEntries.objectAtIndex(indexPath.row) as! NewsEntry).title
//		cell.detailTextLabel?.text = (newsEntries.objectAtIndex(indexPath.row) as! NewsEntry).section
//			// + ", " + (newsEntries.objectAtIndex(indexPath.row) as! NewsEntry).shortDescription!
//		//cell.detailTextLabel!.lineBreakMode = .ByWordWrapping;
//		cell.detailTextLabel!.numberOfLines = 2; // Show 2 lines
		
		let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! UITableViewCell

		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]

		cell.textLabel!.text = tableItem.title
		cell.detailTextLabel?.text = tableItem.shortDescription
		cell.detailTextLabel?.numberOfLines = 2; // Show 2 lines
		
		return cell
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sortedSections[section]
	}
	
    func getHighFiJSON(whichFeed : String){
        println("getHighFiJSON: \(whichFeed)")
		
		Alamofire.request(.GET, whichFeed, parameters: ["APIKEY": APIKEY])
			.responseJSON() { (request, response, JSON, error) in
//				println("request: \(request)")
//				println("response: \(response)")
//				println("json: \(theJSON)")
				
			if error == nil {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
					let data = (JSON!.valueForKey("responseData") as! NSDictionary)
					let feed = (data.valueForKey("feed") as! NSDictionary)
					let entries = (feed.valueForKey("entries") as! [NSDictionary])
						//.filter({ ($0["sectionID"] as! Int) == 98 })
						.map { NewsEntry(
							title: $0["title"] as! String,
							link: $0["link"] as! String,
							author: $0["author"] as! String,
							publishedDateJS: $0["publishedDateJS"] as! String,
							shortDescription: $0["shortDescription"] as? String,
							mobileLink: $0["mobileLink"] as? String,
							sectionID: $0["sectionID"] as! Int,
							//	let picture: String?
							//	let originalPicture: String?
							//	let originalURL: String
							//	let originalMobileUrl: String?
							//	let articleID: Int
							//	let sourceID: Int
							//	let highlight: Bool
							section: "0"
						)
					}
					println("entries: \(entries.count)")
					
					for item in entries {
						item.section = self.getTimeSince(item.publishedDateJS)
					}
					
					dispatch_async(dispatch_get_main_queue()) {
						self.newsEntries.addObjectsFromArray(entries)
						//println("newsEntries=\(self.newsEntries.count)")
						
						// Put each item in a section
						for item in self.newsEntries {
							// If we don't have section for particular time, create new one,
							// Otherwise just add item to existing section
							var foo = item as! NewsEntry
							//println("section=\(foo.section), title=\(foo.title)")
							if self.sections.indexForKey(item.section) == nil {
								self.sections[item.section] = [item as! NewsEntry]
							}
							else {
								self.sections[item.section]!.append(item as! NewsEntry)
							}

							// Storing sections in dictionary, so we need to sort it
							self.sortedSections = self.sections.keys.array.sorted(<)
						}
						//println("sections=\(self.sections.count)")
						
						self.tableView!.reloadData()
						self.refreshControl?.endRefreshing()
						return
					}
				}
			} else {
				println("error: \(error)")
			}
		}
	}
	
	func getTimeSince(item: String) -> String {
		//println("getTimeSince: \(item)")
		if let startDate = dateFormatter.dateFromString(item) {
		//if let startDate = dateFormatter.dateFromString("2015-06-18T9:46:08.000Z") {
			let components = calendar.components(
				NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: startDate, toDate: NSDate(), options: nil)
			let days = components.day
			let hours = components.hour
			let minutes = components.minute
			//println("\(days) days, \(hours) hours, \(minutes) minutes")
			
			if days == 0 {
				if hours == 0 {
					if minutes < 0 { return "Juuri nyt" }
					else if minutes < 5 { return "< 5 minuuttia" }
					else if minutes < 15 { return "< 15 minuuttia" }
					else if minutes < 30 { return "< 30 minuuttia" }
					else if minutes < 45 { return "< 45 minuuttia" }
					else if minutes < 60 { return "< tunti" }
				} else {
					if hours < 24 { return "\(hours) tuntia" }
				}
			} else {
				if days == 1 {
					return "Eilen"
				} else {
					return "\(days) päivää"
				}
			}
		}
		
		return "0"
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
