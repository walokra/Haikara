//
//  FilterNewsSourcesViewController.swift
//  highkara
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Marko Wallin <mtw@iki.fi>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class FilterNewsSourcesViewController: UIViewController {
    
    let viewName = "Settings_FilterNewsSourcesView"

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }

    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tableTitleView: UIView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var searchFooter: SearchFooter!
    let settings = Settings.sharedInstance
	var defaults: UserDefaults?
	
	var navigationItemTitle: String = NSLocalizedString("SETTINGS_FILTERED_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	var searchPlaceholderText: String = NSLocalizedString("FILTER_SEARCH_PLACEHOLDER", comment: "Search sources to filter")
	
    var newsSources = [NewsSources]()
	var filteredTableData = [NewsSources]()
	var searchText: String? = ""
    
    let payWallItems = [Paywall.Free, Paywall.Partial, Paywall.Monthly, Paywall.Strict]
	
	override func viewWillDisappear(_ animated: Bool) {
    	super.viewWillDisappear(animated)
		searchText = searchController.searchBar.text
		searchController.isActive = false
  	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
        self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
		
		if !(searchText?.isEmpty)! {
			searchController.searchBar.text = searchText
			searchController.isActive = true
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
	
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
		if self.newsSources.isEmpty {
            getNewsSources()
        }
        #if DEBUG
            print("newsSources filtered=\(String(describing: settings.newsSourcesFiltered[settings.region]))")
        #endif

        self.tableView!.delegate = self
        self.tableView.dataSource = self
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        } else {
            searchController.dimsBackgroundDuringPresentation = false
        }
        searchController.searchBar.placeholder = searchPlaceholderText
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
//        self.definesPresentationContext = true

        // Setup the Scope Bar
//        searchController.searchBar.scopeButtonTitles = [payWallItems[0].description, payWallItems[1].description, payWallItems[2].description, payWallItems[3].description]
//        searchController.searchBar.showsScopeBar = true
//        searchController.searchBar.delegate = self
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barStyle = Theme.barStyle
        searchController.searchBar.barTintColor = Theme.searchBarTintColor
        searchController.searchBar.backgroundColor = Theme.backgroundColor
        
        self.tableTitleView.addSubview(searchController.searchBar)

        // Setup the search footer
//        tableView.tableFooterView = searchFooter
    }
	
	func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(FilterNewsSourcesViewController.setRegionNewsSources(_:)), name: .regionChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FilterNewsSourcesViewController.resetNewsSourcesFiltered(_:)), name: .settingsResetedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(FilterNewsSourcesViewController.setTheme(_:)), name: .themeChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(FilterNewsSourcesViewController.setContentSize(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
        tableTitleView.backgroundColor = Theme.backgroundColor
	}
	
	@objc func setTheme(_ notification: Notification) {
        #if DEBUG
            print("FilterNewsSourcesViewController, Received themeChangedNotification")
        #endif
		setTheme()
		
		searchController.searchBar.barStyle = Theme.barStyle
        searchController.searchBar.barTintColor = Theme.searchBarTintColor
		searchController.searchBar.backgroundColor = Theme.backgroundColor
		
		self.tableView.reloadData()
	}
	
	func setContentSize() {
		tableView.reloadData()
	}
	
	@objc func setContentSize(_ notification: Notification) {
		#if DEBUG
            print("DetailViewController, Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}
	
    @objc func setRegionNewsSources(_ notification: Notification) {
        #if DEBUG
            print("FilterNewsSourcesViewController, regionChangedNotification")
        #endif
        
        getNewsSources()
    }
    
    @objc func resetNewsSourcesFiltered(_ notification: Notification) {
        #if DEBUG
            print("FilterNewsSourcesViewController, Received resetNewsSourcesFiltered")
        #endif
		
		if (settings.newsSources.isEmpty) {
			getNewsSourcesFromAPI()
		} else {
			self.newsSources = settings.newsSources
		}
		self.tableView!.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
//    func filterContentForSearchText(_ searchText: String, scope: Paywall = Paywall.All) {
//        filteredTableData.removeAll(keepingCapacity: false)
//
//        filteredTableData = newsSources.filter({( newsSource : NewsSources) -> Bool in
//            let doesPaywallMatch = (scope == Paywall.All) || (newsSource.paywall == scope.type)
//
//            if searchBarIsEmpty() {
//                return doesPaywallMatch
//            } else {
//                return doesPaywallMatch && newsSource.sourceName.lowercased().contains(searchText.lowercased())
//            }
//        })
//        tableView.reloadData()
//    }

    func filterContentForSearchText(_ searchText: String) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        filteredTableData = newsSources.filter({( newsSource : NewsSources) -> Bool in
            return newsSource.sourceName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
//    func isFiltering() -> Bool {
//        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
//        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
//    }
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNewsSources(){
        // Get news sources for selected region from settings' store
        if let newsSources: [NewsSources] = self.settings.newsSourcesByLang[self.settings.region] {
			#if DEBUG
				print("filter view, getNewsSources: getting news sources for '\(self.settings.region)' from settings")
                print("newsSources=\(newsSources)")
			#endif
			
			if let updated: Date = self.settings.newsSourcesUpdatedByLang[self.settings.region] {
				let calendar = Calendar.current
				var comps = DateComponents()
				comps.day = 1
				let updatedPlusWeek = (calendar as NSCalendar).date(byAdding: comps, to: updated, options: NSCalendar.Options())
				let today = Date()
				
				#if DEBUG
					print("today=\(today), updated=\(updated), updatedPlusWeek=\(String(describing: updatedPlusWeek))")
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
            print("filter view, getNewsSources: getting news sources for lang from API")
        #endif
        // If news sources for selected region is not found, fetch from API
        getNewsSourcesFromAPI()
    }
    
    
    func getNewsSourcesFromAPI() {
        HighFiApi.listSources(
            { (result) in
                self.settings.newsSources = result
                self.newsSources = result

                self.settings.newsSourcesByLang.updateValue(self.settings.newsSources, forKey: self.settings.region)
                let archivedObject = NSKeyedArchiver.archivedData(withRootObject: self.settings.newsSourcesByLang as Dictionary<String, Array<NewsSources>>)
                self.defaults!.set(archivedObject, forKey: "newsSourcesByLang")
                
                self.settings.newsSourcesUpdatedByLang.updateValue(Date(), forKey: self.settings.region)
                self.defaults!.set(self.settings.newsSourcesUpdatedByLang, forKey: "newsSourcesUpdatedByLang")
//                #if DEBUG
//                    print("news sources updated, \(String(describing: self.settings.newsSourcesUpdatedByLang[self.settings.region]))")
//                #endif
                
                self.defaults!.synchronize()
                
//                #if DEBUG
//                    print("categoriesByLang=\(self.settings.categoriesByLang[self.settings.region])")
//                #endif
                
                self.tableView!.reloadData()
                
                return
        }
            , failureHandler: {(error)in
                self.handleError(error, title: self.errorTitle)
        }
        )
    }
    
    // stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension FilterNewsSourcesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
//            searchFooter.setIsFilteringToShow(filteredItemCount: filteredTableData.count, of: newsSources.count)
            return filteredTableData.count
        }

//        searchFooter.setNotFiltering()
        return newsSources.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: MainStoryboard.TableViewCellIdentifiers.listCategoryCell, for: indexPath)

        var tableItem: NewsSources
        if isFiltering() {
            tableItem = filteredTableData[indexPath.row] as NewsSources
        } else {
            tableItem = newsSources[indexPath.row] as NewsSources
        }

        cell.textLabel!.text = tableItem.sourceName
        cell.textLabel!.textColor = Theme.cellTitleColor
        cell.textLabel!.font = settings.fontSizeXLarge

        if (settings.newsSourcesFiltered[settings.region]?.index(of: tableItem.sourceID) != nil) {
            cell.backgroundColor = Theme.selectedColor
            cell.accessibilityTraits = UIAccessibilityTraitSelected
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
}

extension FilterNewsSourcesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedNewsSource: NewsSources
        if isFiltering() {
            selectedNewsSource = self.filteredTableData[indexPath.row]
        } else {
            selectedNewsSource = self.newsSources[indexPath.row]
        }

        #if DEBUG
            print("didSelectRowAtIndexPath, selectedNewsSource=\(selectedNewsSource.sourceName), \(selectedNewsSource.sourceID)")
        #endif

        self.trackEvent("removeSource", category: "ui_Event", action: "removeSource", label: "settings", value: selectedNewsSource.sourceID as NSNumber)

        let removed = self.settings.removeSource(selectedNewsSource.sourceID)
        self.newsSources[indexPath.row].selected = removed

        defaults!.set(settings.newsSourcesFiltered, forKey: "newsSourcesFiltered")
        defaults!.synchronize()

        self.tableView!.reloadData()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let selectionColor = UIView() as UIView
        selectionColor.backgroundColor = Theme.tintColor
        cell.selectedBackgroundView = selectionColor
    }

}

extension FilterNewsSourcesViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
//    func updateSearchResults(for searchController: UISearchController) {
//        let searchBar = searchController.searchBar
//        let scope = payWallItems[searchBar.selectedScopeButtonIndex]
//        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
//    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

//extension FilterNewsSourcesViewController: UISearchBarDelegate {
//    // MARK: - UISearchBar Delegate
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        filterContentForSearchText(searchBar.text!, scope: payWallItems[selectedScope])
//    }
//}
