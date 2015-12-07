//
//  FilterNewsSources.swift
//  highkara
//
//  Created by Marko Wallin on 25.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

class FilterNewsSourcesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
	
	@IBOutlet weak var titleView: UIView!
	@IBOutlet weak var tableTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let settings = Settings.sharedInstance
    var defaults = NSUserDefaults.standardUserDefaults()
	
	var navigationItemTitle: String = NSLocalizedString("SETTINGS_FILTERED_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
    
    var newsSources = [NewsSources]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
		
		setObservers()
		setTheme()
		
		if self.newsSources.isEmpty {
            getNewsSources()
        }
		
        #if DEBUG
            print("newsSources filtered=\(settings.newsSourcesFiltered[settings.region])")
        #endif
            
        self.tableView!.delegate=self
        self.tableView.dataSource = self
    }
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setRegionNewsSources:", name: "regionChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resetNewsSourcesFiltered:", name: "settingsResetedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "setTheme:", name: "themeChangedNotification", object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
		tableTitleLabel.textColor = Theme.textColor
		titleView.backgroundColor = Theme.backgroundColor
	}
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("FilterNewsSourcesViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
    
    func setRegionNewsSources(notification: NSNotification) {
        #if DEBUG
            print("FilterNewsSourcesViewController, regionChangedNotification")
        #endif
        
        getNewsSources()
    }
    
    func resetNewsSourcesFiltered(notification: NSNotification) {
        #if DEBUG
            print("FilterNewsSourcesViewController, Received resetNewsSourcesFiltered")
        #endif
        
        self.newsSources = settings.newsSources
        self.tableView!.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.newsSources.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listCategoryCell, forIndexPath: indexPath)
        
        let tableItem: NewsSources = newsSources[indexPath.row] as NewsSources
		
        cell.textLabel!.text = tableItem.sourceName
		cell.textLabel!.textColor = Theme.cellTitleColor
        
        if (settings.newsSourcesFiltered[settings.region]?.indexOf(tableItem.sourceID) != nil) {
            cell.backgroundColor = Theme.selectedColor
        } else {
			if (indexPath.row % 2 == 0) {
				cell.backgroundColor = Theme.evenRowColor
			} else {
				cell.backgroundColor = Theme.oddRowColor
			}
        }
        
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedNewsSource = self.newsSources[indexPath.row]
        #if DEBUG
            print("didSelectRowAtIndexPath, selectedNewsSource=\(selectedNewsSource.sourceName), \(selectedNewsSource.sourceID)")
        #endif
        
        var removed: Bool = false
        if var sourceFilteredForLang = settings.newsSourcesFiltered[settings.region] {
            #if DEBUG
                print("sourceFilteredForLang=\(sourceFilteredForLang)")
            #endif
            
            if let index = sourceFilteredForLang.indexOf(selectedNewsSource.sourceID) {
                print("Removing item at index \(index)")
                sourceFilteredForLang.removeAtIndex(index)
                removed = true
                self.newsSources[indexPath.row].selected = false
            }
            if (!removed) {
                print("Adding item to filtered sources, \(selectedNewsSource.sourceID)")
                sourceFilteredForLang.append(selectedNewsSource.sourceID)
                self.newsSources[indexPath.row].selected = true
            }
            settings.newsSourcesFiltered.updateValue(sourceFilteredForLang, forKey: settings.region)
        } else {
            print("Creating new key for language news sources, \(settings.region)")
            settings.newsSourcesFiltered.updateValue([selectedNewsSource.sourceID], forKey: settings.region)
        }
        
        #if DEBUG
            print("newsSourcesFiltered[\(settings.region)]=\(settings.newsSourcesFiltered[settings.region])")
        #endif
        
        defaults.setObject(settings.newsSourcesFiltered, forKey: "newsSourcesFiltered")
        self.tableView!.reloadData()
    }

    func getNewsSources(){
        // Get news sources for selected region from settings' store
        if let newsSources: [NewsSources] = self.settings.newsSourcesByLang[self.settings.region] {
			#if DEBUG
				print("filter view, getNewsSources: getting news sources for '\(self.settings.region)' from settings")
				print("newsSources=\(newsSources)")
			#endif
			
			if let updated: NSDate = self.settings.newsSourcesUpdatedByLang[self.settings.region] {
				let calendar = NSCalendar.currentCalendar()
				let comps = NSDateComponents()
				comps.day = 1
				let updatedPlusWeek = calendar.dateByAddingComponents(comps, toDate: updated, options: NSCalendarOptions())
				let today = NSDate()
				
				#if DEBUG
					print("today=\(today), updated=\(updated), updatedPlusWeek=\(updatedPlusWeek)")
				#endif
					
				if updatedPlusWeek!.isLessThanDate(today) {
					getNewsSourcesFromAPI()
					return
				}
			}
			
			self.settings.newsSources = newsSources
			self.newsSources = newsSources
			
	        self.tableView!.reloadData()

			return
		}

        #if DEBUG
            print("filter view, getCategories: getting news sources for lang from API")
        #endif
        // If categories for selected region is not found, fetch from API
        getNewsSourcesFromAPI()
    }
    
    func getNewsSourcesFromAPI() {
        HighFiApi.listSources(
            { (result) in
                self.settings.newsSources = result
                self.newsSources = result
                
                self.settings.newsSourcesByLang.updateValue(self.settings.newsSources, forKey: self.settings.region)
                let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(self.settings.newsSourcesByLang as Dictionary<String, Array<NewsSources>>)
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(archivedObject, forKey: "newsSourcesByLang")
                
                self.settings.newsSourcesUpdatedByLang.updateValue(NSDate(), forKey: self.settings.region)
                defaults.setObject(self.settings.newsSourcesUpdatedByLang, forKey: "newsSourcesUpdatedByLang")
                #if DEBUG
                    print("news sources updated, \(self.settings.newsSourcesUpdatedByLang[self.settings.region])")
                #endif
                
                defaults.synchronize()
                
//                #if DEBUG
//                    print("categoriesByLang=\(self.settings.categoriesByLang[self.settings.region])")
//                #endif

	        	self.tableView!.reloadData()
			
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
    
    // stop observing
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
