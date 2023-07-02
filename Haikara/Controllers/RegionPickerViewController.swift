//
//  RegionPickerViewController.swift
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

class RegionPickerViewController: UITableViewController {

	let viewName = "Settings_RegionPickerView"

    struct MainStoryboard {
        struct TableViewCellIdentifiers {
            static let listRegionCell = "tableCell"
        }
    }
	
    var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	
    let settings = Settings.sharedInstance
    var defaults: UserDefaults?

    var languages = [Language]()
	var selectedLanguage: Language? {
    	didSet {
            selectedLanguageIndex = languages.firstIndex(of: selectedLanguage!)
		}
  	}
  	var selectedLanguageIndex: Int?

	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		setTheme()
		sendScreenView(viewName)
    }
	
	func setTheme() {
		#if DEBUG
            print("RegionPickerViewController, setTheme()")
        #endif
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		self.tableView.backgroundColor = Theme.backgroundColor
		self.tableView.reloadData()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	  if segue.identifier == "SaveSelectedLanguage" {
    	if let cell = sender as? UITableViewCell {
      		let indexPath = tableView.indexPath(for: cell)
      		if let index = indexPath?.row {
        		selectedLanguage = languages[index]
      		}
    	}
	  }
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
  		return 1
	}
 
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  		return languages.count
	}
 
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  		let cell = tableView.dequeueReusableCell(withIdentifier: MainStoryboard.TableViewCellIdentifiers.listRegionCell, for: indexPath)
		
		let lang: Language = self.languages[indexPath.row]
  		cell.textLabel?.text = lang.country
		
//		if indexPath.row == selectedLanguageIndex {
//    		cell.accessoryType = .Checkmark
//  		} else {
//    		cell.accessoryType = .None
//		}

		cell.textLabel!.textColor = Theme.cellTitleColor
		cell.textLabel!.font = settings.fontSizeXLarge
		
		if indexPath.row == selectedLanguageIndex {
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

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
 
  		//Other row is selected - need to deselect it
  		if let index = selectedLanguageIndex {
    		let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
    		cell?.accessoryType = .none
  		}
 
  		selectedLanguage = languages[indexPath.row]
		settings.region = selectedLanguage!.country
        settings.useToRetrieveLists = selectedLanguage!.useToRetrieveLists
        settings.mostPopularName = selectedLanguage!.mostPopularName
        settings.latestName = selectedLanguage!.latestName
        settings.domainToUse = selectedLanguage!.domainToUse
        settings.genericNewsURLPart = selectedLanguage!.genericNewsURLPart
        #if DEBUG
            print ("selected region = \(settings.region)")
        #endif

        defaults!.set(settings.region, forKey: "region")
        defaults!.set(settings.useToRetrieveLists, forKey: "useToRetrieveLists")
        defaults!.set(settings.mostPopularName, forKey: "mostPopularName")
        defaults!.set(settings.latestName, forKey: "latestName")
        defaults!.set(settings.domainToUse, forKey: "domainToUse")
        defaults!.set(settings.genericNewsURLPart, forKey: "genericNewsURLPart")
		
		defaults!.synchronize()

		self.trackEvent("setRegion", category: "ui_Event", action: "setRegion", label: "settings", value: 1)

        NotificationCenter.default.post(name: .regionChangedNotification, object: nil, userInfo: ["region": selectedLanguage!])
 
  		//update the checkmark for the current row
		let cell = tableView.cellForRow(at: indexPath)
		cell?.backgroundColor = Theme.selectedColor
//  		cell?.accessoryType = .Checkmark
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
	    let selectionColor = UIView() as UIView
	    selectionColor.backgroundColor = Theme.tintColor
	    cell.selectedBackgroundView = selectionColor
	}
	
	// stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
