//
//  HideCategoryViewController.swift
//  highkara
//
//  Created by Marko Wallin on 20.10.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

class HideCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    let settings = Settings.sharedInstance
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    var categories = [Category]()
    
    // white smoke
    let normalColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    // high green
    let selectedColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.categories = settings.categories
        
        print("categories hidden=\(settings.categoriesHidden[settings.region])")
        
        self.tableView!.delegate=self
        self.tableView.dataSource = self
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
        
        if (settings.categoriesHidden[settings.region]?.indexOf(tableItem.sectionID) != nil) {
            cell.backgroundColor = selectedColor
        } else {
            cell.backgroundColor = normalColor
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        print("didSelectRowAtIndexPath, selectedCategory=\(selectedCategory.title), \(selectedCategory.sectionID)")
        
        var removed: Bool = false
        if var catHiddenForLang = settings.categoriesHidden[settings.region] {
            print("catHiddenForLang=\(catHiddenForLang)")
            
            if let index = catHiddenForLang.indexOf(selectedCategory.sectionID) {
                print("Removing item at index \(index)")
                catHiddenForLang.removeAtIndex(index)
                removed = true
                self.categories[indexPath.row].selected = false
            }
            if (!removed) {
                print("Adding item to hidden categories, \(selectedCategory.sectionID)")
                catHiddenForLang.append(selectedCategory.sectionID)
                self.categories[indexPath.row].selected = true
            }
            settings.categoriesHidden.updateValue(catHiddenForLang, forKey: settings.region)
        } else {
            print("Creating new key for language categories, \(settings.region)")
            settings.categoriesHidden.updateValue([selectedCategory.sectionID], forKey: settings.region)
        }
        
        print("categoriesHidden[region]=\(settings.categoriesHidden[settings.region])")
        
        defaults.setObject(settings.categoriesHidden, forKey: "categoriesHidden")
        self.tableView!.reloadData()
//        NSNotificationCenter.defaultCenter().postNotificationName("selectedCategoriesChangedNotification", object: nil, userInfo: ["categories": "much categories"]) //userInfo parameter has to be of type [NSObject : AnyObject]?
        
    }

}
