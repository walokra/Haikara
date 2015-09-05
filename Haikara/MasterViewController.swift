//
//  SlideOutViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit

protocol CategorySelectionDelegate: class {
    func categorySelected(newCategory: Category)
}

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    let settings = Settings.sharedInstance
    

    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonAction(sender: AnyObject) {
    }
    @IBOutlet weak var slideOutTableView: UITableView!
    let cellIdentifier = "tableCell"
    
    var categories = [Category]()
    var currentLanguage: String = "Finland"
    
    weak var delegate: CategorySelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "app-logo_40x40.png")
        self.navigationItem.titleView = UIImageView(image: logo)
        
        // creating settings button from font
        var settingsButtonString = String.ionIconString("ion-ios-gear-outline")
        var settingsButtonStringAttributed = NSMutableAttributedString(string: settingsButtonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
        settingsButtonStringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("ionicons", fontSize: 32), range: NSRange(location: 0,length: 1))
        settingsButtonStringAttributed.addAttribute(
            NSForegroundColorAttributeName,
            value: UIColor.blackColor(),
            range: NSRange(location: 0,length: 1)
        )
        
        settingsButton.titleLabel?.textAlignment = .Center
        settingsButton.titleLabel?.numberOfLines = 1
        settingsButton.setAttributedTitle(settingsButtonStringAttributed, forState: .Normal)
        //
        
        currentLanguage = settings.region
        
        getCategories()
        
        self.slideOutTableView!.delegate=self
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

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        self.delegate?.categorySelected(selectedCategory)
        
        if let detailViewController = self.delegate as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController.navigationController, sender: nil)
        }

        splitViewController?.preferredDisplayMode = .PrimaryHidden
        splitViewController?.preferredDisplayMode = .Automatic
    }
    
    // stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
