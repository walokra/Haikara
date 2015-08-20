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

    let settings = Settings.sharedInstance
    
    @IBOutlet weak var slideOutTableView: UITableView!
    let cellIdentifier = "tableCell"
    
    var categories = [Category]()
    var currentLanguage: String = "Finland"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "app-logo_40x40.png")
        self.navigationItem.titleView = UIImageView(image: logo)
        
        currentLanguage = settings.region
        
   		setHeaders()
        
        getHighFiCategories()
        
        self.slideOutTableView.dataSource = self
    }
    
    func setHeaders() {
        // Specifying the Headers
        Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = [
            "User-Agent": settings.appID,
            "Cache-Control": "private, must-revalidate, max-age=84600"
        ]
    }

    func getHighFiCategories(){
        let url = "http://" + settings.domainToUse + "/api/"
        println("getHighFiCategories()")
        
        Manager.sharedInstance.request(.GET, url, parameters: ["act": settings.highFiActCategory, "usedLanguage": settings.useToRetrieveLists, "APIKEY": settings.APIKEY])
            .responseJSON() { (request, response, JSON, error) in
                println("request: \(request)")
                // println("response: \(response)")
                // println("json: \(theJSON)")
                
                if error == nil {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                        let data = (JSON!.valueForKey("responseData") as! NSDictionary)
                        var categories = (data.valueForKey("categories") as! [NSDictionary])
                            .filter({ ($0["depth"] as! Int) == 1 })
                            .map { Category(
                                title: $0["title"] as! String,
                                sectionID: $0["sectionID"] as! Int,
                                depth: $0["depth"] as! Int,
                                htmlFilename: $0["htmlFilename"] as! String
                                )
                        }
//                        println("categories: \(categories.count)")
                        var cat = [Category]()
                        cat.append(Category(title: self.settings.latestName, sectionID: 0, depth: 1, htmlFilename: self.settings.genericNewsURLPart))
                        cat.append(Category(title: self.settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top"))
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.categories = cat + categories
                            self.slideOutTableView!.reloadData()
                            return
                        }
                    }
                } else {
                    #if DEBUG
                        println("error: \(error)")
                    #endif
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
        
        let tableItem: Category = categories[indexPath.row] as Category
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
            let tableItem: Category = categories[row] as Category

            (segue.destinationViewController as! ViewController).navigationItemTitle = tableItem.title
            (segue.destinationViewController as! ViewController).highFiSection = tableItem.htmlFilename
        }
    }

}
