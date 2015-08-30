//
//  SlideOutViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

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
        
        getCategories()
        
        self.slideOutTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setRegionCategory:", name: "regionChangedNotification", object: nil)
    }
    
    func setRegionCategory(notification: NSNotification) {
        #if DEBUG
            println("Received regionChangedNotification")
            println(notification.userInfo)
        #endif
        
        getCategories()
    }

    func getCategories(){
        HighFiApi.getCategories() {
            (result: [Category]) in
            dispatch_async(dispatch_get_main_queue()) {
                self.categories = result
                self.slideOutTableView!.reloadData()
                return
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
    
    // stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
