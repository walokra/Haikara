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

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
    
    let settings = Settings.sharedInstance

    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonAction(sender: AnyObject) {
    }
    @IBOutlet weak var slideOutTableView: UITableView!
    
    var categories = [Category]()
    var currentLanguage: String = "Finland"
    
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    weak var delegate: CategorySelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "app-logo_40x40.png")
        self.navigationItem.titleView = UIImageView(image: logo)
        
        // creating settings button from font
        let settingsButtonString = String.ionIconString("ion-ios-gear-outline")
        let settingsButtonStringAttributed = NSMutableAttributedString(string: settingsButtonString, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 11.00)!])
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
        
        if self.categories.isEmpty {
            getCategories()
        }
        
        self.slideOutTableView!.delegate=self
        self.slideOutTableView.dataSource = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setRegionCategory:", name: "regionChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateSelectedCategories:", name: "selectedCategoriesChangedNotification", object: nil)
    }
    
    func setRegionCategory(notification: NSNotification) {
        #if DEBUG
            print("Received regionChangedNotification")
            print(notification.userInfo)
        #endif
        
        getCategories()
    }
    
    func updateSelectedCategories(notification: NSNotification) {
        #if DEBUG
            print("Received selectedCategoriesChangedNotification")
            print(notification.userInfo)
        #endif
        setCategories()
    }
    
    func setCategories() {
        print("setCategories")
        
        // Adding always present categories: generic and top
        var cat = [Category]()
        cat.append(Category(title: settings.latestName, sectionID: 0, depth: 1, htmlFilename: settings.genericNewsURLPart, selected: true))
        cat.append(Category(title: settings.mostPopularName, sectionID: 1, depth: 1, htmlFilename: "top", selected: true))
        
        if let categoriesFavorited = settings.categoriesFavorited[settings.region] {
            print("showing selected categories=\(categoriesFavorited)")
            
            if categoriesFavorited.isEmpty {
                self.categories = cat + self.settings.categories
            } else {
                var filteredCategories = [Category]()
            
                self.settings.categories.forEach({ (category: Category) -> () in
                    if categoriesFavorited.contains(category.sectionID) {
                        filteredCategories.append(category)
                    }
                })
            
                self.categories = cat + filteredCategories
            }
        } else {
            self.categories = cat + self.settings.categories
        }

        self.slideOutTableView!.reloadData()
    }

    func getCategories(){
        HighFiApi.getCategories(
            { (result) in
                self.settings.categories = result
                self.categories = result
                self.setCategories()
                return
            }
            , failureHandler: {(error)in
                self.handleError(error)
            }
        )
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.categories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listCategoryCell, forIndexPath: indexPath) 

        let tableItem: Category = categories[indexPath.row] as Category
        cell.textLabel!.text = tableItem.title
        cell.indentationLevel = tableItem.depth
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        
        if let detailViewController = self.delegate as? DetailViewController {
            self.delegate?.categorySelected(selectedCategory)
            splitViewController?.showDetailViewController(detailViewController.navigationController!, sender: nil)
        }

        splitViewController?.preferredDisplayMode = .PrimaryHidden
        splitViewController?.preferredDisplayMode = .Automatic
    }
    
    // stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
