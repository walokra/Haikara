//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

import Alamofire

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "tableCell"
	var entries = NSMutableOrderedSet()
	
	var sections = Dictionary<String, Array<Entry>>()
	var sortedSections = [String]()

	var highFiBase: String = "http://fi.high.fi"
	let highFiEndpoint: String = "json-private"
	var highFiSection: String = "uutiset"
	
	var navigationItemTitle: String = "Uutiset";

	@IBOutlet weak var tableView: UITableView!

	var refreshControl:UIRefreshControl!

	let calendar = NSCalendar.autoupdatingCurrentCalendar()
	let dateFormatter = NSDateFormatter()
	
	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.navigationItem.title = navigationItemTitle
		self.tableView!.dataSource = self

		configureTableView()
		
		calendar.timeZone = NSTimeZone.systemTimeZone()
		dateFormatter.timeZone = calendar.timeZone
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"

		getHighFiJSON()
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: "Vedä alas päivittääksesi")
		self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75.0
	}
	
	func refresh(sender:AnyObject) {
//		println("refresh: \(sender)")
		getHighFiJSON()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "NewsItemDetails" {
			let path = self.tableView!.indexPathForSelectedRow()!
			let row = path.row
			
			let tableSection = sections[sortedSections[path.section]]
			let tableItem = tableSection![row]
			
//			println("mobileLink= \(tableItem.mobileLink), link= \(tableItem.link)")
			(segue.destinationViewController as! NewsItemViewController).title = tableItem.title
			if (tableItem.mobileLink?.isEmpty != nil) {
				(segue.destinationViewController as! NewsItemViewController).webSite = tableItem.link
			} else {
				(segue.destinationViewController as! NewsItemViewController).webSite = tableItem.mobileLink
			}
		}
	}

    // MARK: - Table view data source

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
//		println("cell=\(cell)")
//		println("cell.entryTitle=\(cell.entryTitle)")

		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
//		println("tableItem=\(tableItem)")
		cell.entryTitle.text = tableItem.title
		cell.entryAuthor.text = tableItem.author
		if tableItem.shortDescription != "" {
			cell.entryDescription!.text = tableItem.shortDescription
			//cell.entryDescription!.numberOfLines = 2; // Show 2 lines
		}
		
		return cell
    }
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sortedSections[section]
	}
	
    func getHighFiJSON(){
		let feed = highFiBase + "/" + highFiSection + "/" + highFiEndpoint
        println("getHighFiJSON: \(feed)")
		
		Alamofire.request(.GET, feed, parameters: ["APIKEY": APIKEY])
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
						.map { Entry(
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
							section: "Juuri nyt"
						)
					}
//					println("entries: \(entries.count)")
					
					for item in entries {
						item.section = self.getTimeSince(item.publishedDateJS)
					}
					
					dispatch_async(dispatch_get_main_queue()) {
						self.entries.addObjectsFromArray(entries)
						//println("newsEntries=\(self.newsEntries.count)")
						
						// Put each item in a section
						for item in self.entries {
							// If we don't have section for particular time, create new one,
							// Otherwise just add item to existing section
							var entry = item as! Entry
//							println("section=\(entry.section), title=\(entry.title)")
							if self.sections.indexForKey(entry.section) == nil {
								self.sections[entry.section] = [entry]
							} else {
								self.sections[entry.section]!.append(entry)
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
					if hours < 24 { return "< \(hours) tuntia" }
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
