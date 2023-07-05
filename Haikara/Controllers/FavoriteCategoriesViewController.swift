//
//  FavoriteCategoriesViewController.swift
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

class FavoriteCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
	
	let viewName = "Settings_FavoriteCategoriesView"
	
    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listCategoryCell = "tableCell"
        }
    }
    
    let settings = Settings.sharedInstance
	var defaults: UserDefaults?
	
	var navigationItemTitle: String = NSLocalizedString("SETTINGS_FAVORITES_TITLE", comment: "")
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")

	@IBOutlet weak var titleView: UIView!
	@IBOutlet weak var tableTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [Category]()
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.tabBarController!.title = navigationItemTitle
        self.navigationItem.title = navigationItemTitle
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		setObservers()
		setTheme()
		setContentSize()
		sendScreenView(viewName)
		
        self.categories = settings.categories
        
        #if DEBUG
            print("selected categories=\(String(describing: settings.categoriesFavorited[settings.region]))")
        #endif
        
        self.tableView!.delegate=self
        self.tableView.dataSource = self
    }
	
	func setObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(FavoriteCategoriesViewController.setRegionCategory(_:)), name: .categoriesRefreshedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FavoriteCategoriesViewController.resetFavorited(_:)), name: .settingsResetedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(FavoriteCategoriesViewController.setTheme(_:)), name: .themeChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(FavoriteCategoriesViewController.setContentSize(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
		tableTitleLabel.textColor = Theme.textColor
		titleView.backgroundColor = Theme.backgroundColor
	}
	
	@objc func setTheme(_ notification: Notification) {
        #if DEBUG
            print("FavoriteCategoriesView, Received themeChangedNotification")
        #endif
		setTheme()
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
	
    @objc func setRegionCategory(_ notification: Notification) {
        #if DEBUG
            print("Received categoriesRefreshedNotification")
        #endif
        
        self.categories = settings.categories
        self.tableView!.reloadData()
    }
    
    @objc func resetFavorited(_ notification: Notification) {
        #if DEBUG
            print("Received settingsResetedNotification")
        #endif

        self.categories = settings.categories
        self.tableView!.reloadData()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell for this indexPath
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: MainStoryboard.TableViewCellIdentifiers.listCategoryCell, for: indexPath)
        
        let tableItem: Category = categories[indexPath.row] as Category
        
        cell.textLabel!.text = tableItem.title
        cell.indentationLevel = (tableItem.depth == 1) ? 0 : tableItem.depth + 1
		cell.textLabel!.textColor = Theme.cellTitleColor
		cell.textLabel!.font = settings.fontSizeXLarge
        
        if (settings.categoriesFavorited[settings.region]?.firstIndex(of: tableItem.sectionID) != nil) {
            cell.backgroundColor = Theme.selectedColor
			cell.accessibilityTraits = UIAccessibilityTraits.selected
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCategory = self.categories[indexPath.row]
        #if DEBUG
            print("didSelectRowAtIndexPath, selectedCategory=\(selectedCategory.title), \(selectedCategory.sectionID)")
        #endif
        
        var removed: Bool = false
        if var langFavoriteCats = settings.categoriesFavorited[settings.region] {
            #if DEBUG
                print("langFavoriteCats=\(langFavoriteCats)")
            #endif
            
            if let index = langFavoriteCats.firstIndex(of: selectedCategory.sectionID) {
                langFavoriteCats.remove(at: index)
                removed = true
                self.categories[indexPath.row].selected = false
            }
            if (!removed) {
                langFavoriteCats.append(selectedCategory.sectionID)
                self.categories[indexPath.row].selected = true
            }
            settings.categoriesFavorited.updateValue(langFavoriteCats, forKey: settings.region)
        } else {
            settings.categoriesFavorited.updateValue([selectedCategory.sectionID], forKey: settings.region)
        }
        
        #if DEBUG
            print("langFavoriteCats=\(String(describing: settings.categoriesFavorited[settings.region]))")
        #endif
        
        defaults!.set(settings.categoriesFavorited, forKey: "categoriesFavorited")
		defaults!.synchronize()
		
        self.tableView!.reloadData()
        NotificationCenter.default.post(name: .selectedCategoriesChangedNotification, object: nil, userInfo: ["categories": "much categories"])
    }
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
	    let selectionColor = UIView() as UIView
	    selectionColor.backgroundColor = Theme.tintColor
	    cell.selectedBackgroundView = selectionColor
	}
	
    // stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
