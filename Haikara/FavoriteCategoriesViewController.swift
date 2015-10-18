//
//  FavoriteCategoriesViewController.swift
//  highkara
//
//  Created by Marko Wallin on 6.10.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

class FavoriteCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
    
    let settings = Settings.sharedInstance
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")

    @IBOutlet weak var tableView: UITableView!
    
    var highfiCategories = [Category]()
    
    // white smoke
    let normalColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    // high green
    let selectedColor = UIColor(red: 90.0/255.0, green: 178.0/255.0, blue: 168.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.highfiCategories = settings.categories
        
        print("selected categories=\(settings.favoriteCategories[settings.region])")
        
        self.tableView!.delegate=self
        self.tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.highfiCategories.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listCategoryCell, forIndexPath: indexPath)
        
        let tableItem: Category = highfiCategories[indexPath.row] as Category
        
        cell.textLabel!.text = tableItem.title
        
        if (settings.favoriteCategories[settings.region]?.indexOf(tableItem.sectionID) != nil) {
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
        let selectedCategory = self.highfiCategories[indexPath.row]
        print("didSelectRowAtIndexPath, selectedCategory=\(selectedCategory.title), \(selectedCategory.sectionID)")
        
        var removed: Bool = false
        if var langFavoriteCats = settings.favoriteCategories[settings.region] {
            print("langFavoriteCats=\(langFavoriteCats)")
            
            if let index = langFavoriteCats.indexOf(selectedCategory.sectionID) {
                print("Removing item at index \(index)")
                langFavoriteCats.removeAtIndex(index)
                removed = true
                self.highfiCategories[indexPath.row].selected = false
            }
            if (!removed) {
                print("Adding item to favorite categories, \(selectedCategory.sectionID)")
                langFavoriteCats.append(selectedCategory.sectionID)
                self.highfiCategories[indexPath.row].selected = true
            }
            settings.favoriteCategories.updateValue(langFavoriteCats, forKey: settings.region)
        } else {
            print("Creating new key for language categories, \(settings.region)")
            settings.favoriteCategories.updateValue([selectedCategory.sectionID], forKey: settings.region)
        }
        
        print("langFavoriteCats=\(settings.favoriteCategories[settings.region])")
        
        defaults.setObject(settings.favoriteCategories, forKey: "categories")
        self.tableView!.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName("selectedCategoriesChangedNotification", object: nil, userInfo: ["categories": "much categories"]) //userInfo parameter has to be of type [NSObject : AnyObject]?

    }
    

}
