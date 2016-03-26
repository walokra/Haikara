//
//  FilterNewsSources.swift
//  highkara
//
//  Created by Marko Wallin on 25.11.2015.
//  Copyright © 2015 Rule of tech. All rights reserved.
//

import UIKit

class FilterNewsSourcesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }

	var searchController: UISearchController!

	@IBOutlet weak var tableTitleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let settings = Settings.sharedInstance
    var defaults = NSUserDefaults.standardUserDefaults()
	
	var navigationItemTitle: String = NSLocalizedString("SETTINGS_FILTERED_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	var searchPlaceholderText: String = NSLocalizedString("FILTER_SEARCH_PLACEHOLDER", comment: "Search sources to filter")
	
    var newsSources = [NewsSources]()
	var filteredTableData = [NewsSources]()

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
		
		self.searchController = ({
			let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
			controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.barStyle = Theme.barStyle
            controller.searchBar.barTintColor = Theme.searchBarTintColor
            controller.searchBar.backgroundColor = Theme.backgroundColor
			controller.searchBar.placeholder = searchPlaceholderText
//            self.tableView.tableHeaderView = controller.searchBar
			self.tableTitleView.addSubview(controller.searchBar)
            return controller
        })()

    }
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FilterNewsSourcesViewController.setRegionNewsSources(_:)), name: "regionChangedNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FilterNewsSourcesViewController.resetNewsSourcesFiltered(_:)), name: "settingsResetedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FilterNewsSourcesViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
		tableTitleView.backgroundColor = Theme.backgroundColor
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
	
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		filteredTableData.removeAll(keepCapacity: false)
		
        let searchPredicate = NSPredicate(format: "sourceName like[c] %@", "*" + searchController.searchBar.text! + "*")

        let array = (newsSources as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [NewsSources]
		#if DEBUG
//			print("search=\(searchController.searchBar.text), filteredTableData.count=\(filteredTableData.count)");
		#endif

        self.tableView.reloadData()
	}

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
		if self.searchController.active {
		   return self.filteredTableData.count
        } else{
		  return self.newsSources.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(MainStoryboard.TableViewCellIdentifiers.listCategoryCell, forIndexPath: indexPath)
		
		var tableItem: NewsSources
		if self.searchController.active {
			tableItem = filteredTableData[indexPath.row] as NewsSources
        } else {
			tableItem = newsSources[indexPath.row] as NewsSources
        }
			
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
		var selectedNewsSource: NewsSources
		if self.searchController.active {
			selectedNewsSource = self.filteredTableData[indexPath.row]
		} else {
			selectedNewsSource = self.newsSources[indexPath.row]
		}

        #if DEBUG
            print("didSelectRowAtIndexPath, selectedNewsSource=\(selectedNewsSource.sourceName), \(selectedNewsSource.sourceID)")
        #endif
        
		let removed = self.settings.removeSource(selectedNewsSource.sourceID)
		self.newsSources[indexPath.row].selected = removed
        
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
