//
//  InfoController.swift
//  Haikara
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

class InfoController: UITableViewController {

	let viewName = "InfoView"

	let settings = Settings.sharedInstance

	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var licenseLabel: UILabel!
	@IBOutlet weak var aboutLabel: UILabel!

	@IBOutlet weak var infoCell: UITableViewCell!
	@IBOutlet weak var logoCell: UITableViewCell!
	
	@IBOutlet weak var openHighFiButton: UIButton!
	@IBAction func openHighFi(_ sender: AnyObject) {
		UIApplication.shared.openURL(URL(string: "http://high.fi/")!)
	}

	@IBOutlet weak var openAppStoreButton: UIButton!
	@IBAction func openAppStore(_ sender: AnyObject) {
		UIApplication.shared.openURL(URL(string: "http://itunes.apple.com/us/app/highkara-uutislukija/id1035170336")!)
	}

	@IBOutlet weak var openTwitterButton: UIButton!
	@IBAction func openTwitter(_ sender: AnyObject) {
	let url = URL(string: "twitter://user?screen_name=walokra")
		if UIApplication.shared.canOpenURL(url!) {
			UIApplication.shared.openURL(url!)
		} else {
	        UIApplication.shared.openURL(URL(string: "https://twitter.com/walokra")!)
		}
	}

	@IBOutlet weak var bugsButton: UIButton!
	@IBAction func openBugs(_ sender: AnyObject) {
		UIApplication.shared.openURL(URL(string: "https://github.com/walokra/haikara/issues")!)
	}

	@IBOutlet weak var openEmailButton: UIButton!
	@IBAction func openEmail(_ sender: AnyObject) {
		UIApplication.shared.openURL(URL(string: "mailto:marko.wallin@iki.fi")!)
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		setObservers()
		setContentSize()
		setTheme()
		configureTableView()
		
		sendScreenView(viewName)
		
        infoLabel.text = settings.appID + ", Marko Wallin"
	}
	
	func setObservers() {
		NotificationCenter.default.addObserver(self, selector: #selector(InfoController.setTheme(_:)), name: .themeChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(InfoController.setContentSize(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		self.view.backgroundColor = Theme.backgroundColor
		
		aboutLabel.textColor = Theme.textColor
		licenseLabel.textColor = Theme.textColor
		openAppStoreButton.setTitleColor(Theme.buttonColor, for: UIControlState())
		openHighFiButton.setTitleColor(Theme.buttonColor, for: UIControlState())
		bugsButton.setTitleColor(Theme.buttonColor, for: UIControlState())
		openTwitterButton.setTitleColor(Theme.buttonColor, for: UIControlState())
		openEmailButton.setTitleColor(Theme.buttonColor, for: UIControlState())
		
		infoLabel.textColor = Theme.textColor
	}
	
	func setTheme(_ notification: Notification) {
		#if DEBUG
            print("Received themeChangedNotification")
        #endif
		setTheme()
    }
	
	func setContentSize() {
		infoLabel.font = settings.fontSizeSmall
		aboutLabel.font = settings.fontSizeLarge
		licenseLabel.font = settings.fontSizeSmall
		openAppStoreButton.titleLabel?.font = settings.fontSizeLarge
		openHighFiButton.titleLabel?.font = settings.fontSizeLarge
		bugsButton.titleLabel?.font = settings.fontSizeLarge
		openTwitterButton.titleLabel?.font = settings.fontSizeLarge
		openEmailButton.titleLabel?.font = settings.fontSizeLarge
		
		tableView.reloadData()
	}
	
	func setContentSize(_ notification: Notification) {
		#if DEBUG
            print("Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
    }

	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 75.0
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		// Change the color of all cells
		cell.backgroundColor = (cell == logoCell) ? UIColor.darkGray : Theme.backgroundColor
		
		cell.textLabel!.textColor = Theme.cellTitleColor
		
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)
		cell.selectionStyle = .none
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))

		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor
		
		var sectionLabel: UILabel
		sectionLabel = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width/2, height: 25))
		sectionLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
		sectionLabel.textColor = Theme.sectionTitleColor
		sectionLabel.font = settings.fontSizeLarge
		
		headerView.addSubview(sectionLabel)
		
    	return headerView
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
