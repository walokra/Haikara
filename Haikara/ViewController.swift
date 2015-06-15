//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	let cellIdentifier = "tableCell"
    var tableData = []
	@IBOutlet weak var tableView: UITableView?

	// MARK: Lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView!.dataSource = self

		// place tableview below status bar
//		self.tableView?.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
//		self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)

        getHighFiJSON("http://fi.high.fi/news/json-private?APIKEY=1234567890")
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "NewsItemDetails" {
			let path = self.tableView!.indexPathForSelectedRow()!
			let row = path.row
			let highfiEntry : NSMutableDictionary = self.tableData[row] as! NSMutableDictionary
//			println("prepareForSegue, highfiEntry: \(highfiEntry)")
			
			let itemViewController = segue.destinationViewController as! NewsItemViewController
			itemViewController.webSite = highfiEntry["link"] as? String
		}
	}
	
//	// Row selection
//	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//		NSLog("Selected row number: \(indexPath.row)!")
//		//self.performSegueWithIdentifier("NewsItemDetails", sender: self)
//	}

    // MARK: - Table view data source

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return tableData.count
    }
	
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: self.cellIdentifier)
		let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
		
        let highfiEntry : NSMutableDictionary = self.tableData[indexPath.row] as! NSMutableDictionary
//        println("highfiEntry: \(highfiEntry)")
		
		if let title = highfiEntry["title"] as? String {
			cell.textLabel!.text = title
		}
		if let desc = highfiEntry["shortDescription"] as? String {
			cell.detailTextLabel?.text = desc
		}

		return cell
    }
	
    func getHighFiJSON(whichFeed : String){
        println("getHighFiJSON: \(whichFeed)")
        let mySession = NSURLSession.sharedSession()
        let url: NSURL = NSURL(string: whichFeed)!
        let networkTask = mySession.dataTaskWithURL(url, completionHandler : {data, response, error -> Void in
            var err: NSError?
            var theJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            let response : NSDictionary = theJSON["responseData"] as! NSDictionary
            let feed : NSDictionary = response["feed"] as! NSDictionary
//            println("feed: \(feed)")
            let results : NSArray = feed["entries"] as! NSArray
//            println("results: \(results)")
            dispatch_async(dispatch_get_main_queue(), {
                self.tableData = results
                self.tableView!.reloadData()
            })
        })
        networkTask.resume()
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
