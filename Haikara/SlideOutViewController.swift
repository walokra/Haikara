//
//  SlideOutViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import Alamofire

class SlideOutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var slideOutTableView: UITableView!
    let cellIdentifier = "tableCell"
    
    var categories = []
    
    // http://fi.high.fi/api/?act=listCategories&usedLanguage=finnish
    var highFiAPIBase: String = "http://fi.high.fi/api"
    let highFiActCategory: String = "listCategories"
    var highFiActUsedLanguage: String = "usedLanguage"
    var highFiLanguage: String = "finnish"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getHighFiCategories()
        
//        println("newsSources= \(newsSources.count)")
        self.slideOutTableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
//        self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // Return the number of sections.
//        return self.newsSources.count
//    }
    
    func getHighFiCategories(){
        let url = highFiAPIBase + "/?act=" + highFiActCategory + "&" + highFiActUsedLanguage + "=" + highFiLanguage
        println("getHighFiCategories: \(url)")
        
        Alamofire.request(.GET, url, parameters: ["APIKEY": APIKEY])
            .responseJSON() { (request, response, JSON, error) in
                //				println("request: \(request)")
                //				println("response: \(response)")
                //				println("json: \(theJSON)")
                
                if error == nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let data = (JSON!.valueForKey("responseData") as! NSDictionary)
                        let categories = (data.valueForKey("categories") as! [NSDictionary])
                            .filter({ ($0["depth"] as! Int) == 1 })
                            .map { Category(
                                title: $0["title"] as! String,
                                sectionID: $0["sectionID"] as! Int,
                                depth: $0["depth"] as! Int,
                                htmlFilename: $0["htmlFilename"] as! String
                                )
                        }
//                        println("categories: \(categories.count)")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.categories = categories
                            self.slideOutTableView!.reloadData()
                            return
                        }
                    }
                } else {
                    println("error: \(error)")
                }
        }
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let tableItem: Category = categories[indexPath.row] as! Category
//        println("tableItem=\(tableItem)")
        
        cell.textLabel!.text = tableItem.title
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "categorySelected" {
            // Get the new view controller using [segue destinationViewController].
            // Pass the selected object to the new view controller.
            let path = self.slideOutTableView!.indexPathForSelectedRow()!
            let row = path.row
            let tableItem: Category = categories[row] as! Category

            (segue.destinationViewController as! ViewController).navigationItemTitle = tableItem.title
            (segue.destinationViewController as! ViewController).highFiSection = tableItem.htmlFilename
        }
    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // Return the number of rows in the section.
//        return newsSources.count
//    }

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

}
