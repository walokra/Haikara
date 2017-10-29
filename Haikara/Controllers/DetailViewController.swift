//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import SafariServices
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DetailViewController: UIViewController, SFSafariViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UISearchBarDelegate {

    let animator = SCModalPushPopAnimator()
	
	let viewName = "MainView"

	@IBOutlet weak var searchBar: UISearchBar!
	var searchActive : Bool = false

	let cellIdentifier = "tableCell"
	var entries = [Entry]()
	var newsEntriesUpdatedByLang = Dictionary<String, Date>()
	
	let settings = Settings.sharedInstance
	var defaults: UserDefaults?
	
	var page: Int = 1
	
	var sections = OrderedDictionary<String, Array<Entry>>()
	var sortedSections = [String]()
	
	// default section
	var highFiSection: String = "uutiset"
	
	var navigationItemTitle: String = ""
	var errorTitle: String = NSLocalizedString("ERROR", comment: "Title for error alert")
	var shareButtonText: String = NSLocalizedString("SHARE_BUTTON", comment: "Text for share button")
	var deleteButtonText: String = NSLocalizedString("DELETE_BUTTON", comment: "Text for delete button")
	var browserButtonText: String = NSLocalizedString("BROWSER_BUTTON", comment: "Text for browser button")
	var deleteAlertText: String = NSLocalizedString("DELETE_ACTION_DESC", comment: "Text for delete action description button")
	var cancelText: String = NSLocalizedString("CANCEL_BUTTON", comment: "Text for cancel")
	var searchTitle: String = NSLocalizedString("SEARCH_TITLE", comment: "Title for search")

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var poweredLabel: UILabel!

	var refreshControl: UIRefreshControl!

	let calendar = Calendar.autoupdatingCurrent
	let dateFormatter = DateFormatter()
	let publishedFormatter = DateFormatter()
	let publishedTimeFormatter = DateFormatter()
	
	let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
	var loading = false
	
	var didSearch: Bool = false
	
	// Icons
	var clockLabel: UILabel!

	// MARK: Search
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        dismissKeyboard()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
		self.title = self.navigationItemTitle
		getNews(1, forceRefresh: self.didSearch)
		self.didSearch = false
		self.scrollToTop()
		dismissKeyboard()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		let searchText = searchBar.text?.trimmingCharacters(
    		in: CharacterSet.whitespacesAndNewlines
		)
		if searchText?.characters.count > 2 {
        	searchActive = false
			didSearch = true
			self.search(searchBar.text!)
			dismissKeyboard()
		}
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		searchActive = true
		self.title = searchTitle
    }
	
	func dismissKeyboard(){
    	self.searchBar.endEditing(true)
	}

	// MARK: Lifecycle

    override func viewDidLoad() {
		#if DEBUG
			print("viewDidLoad()")
		#endif
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		// Check for force touch feature, and add force touch/previewing capability.
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: tableView)
        }

		searchBar.showsCancelButton = true		
		searchBar.delegate = self

		setObservers()
		setTheme()
		setContentSize()
		setLoadingIndicator()
		sendScreenView(viewName)
		
		if navigationItemTitle.isEmpty {
			self.navigationItemTitle = settings.latestName
		}
		
		initView()
		
		// Reset delegates url after we've opened it
    	let delegate = UIApplication.shared.delegate as? AppDelegate
    	if (delegate?.openUrl) != nil {
        	delegate?.openUrl = nil
    	}
    }
	
	func initView() {
		#if DEBUG
			print("initView()")
		#endif
		self.navigationItem.title = navigationItemTitle
		
		self.tableView!.delegate=self
		self.tableView!.dataSource = self
		
		configureTableView()
		
		var localTimeZone: String { return NSTimeZone.local.abbreviation() ?? "" }

		dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
		publishedFormatter.timeZone = TimeZone(abbreviation: localTimeZone)
		publishedFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
		publishedTimeFormatter.timeZone = TimeZone(abbreviation: localTimeZone)
		publishedTimeFormatter.dateFormat = "HH:mm"
		
		// self.tableFooter.hidden = true
	
		self.page = 1
		getNews(self.page, forceRefresh: true)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("REFRESH", comment: "Refresh the news"))
		self.refreshControl.addTarget(self, action: #selector(DetailViewController.refresh(_:)), for: UIControlEvents.valueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	// MARK: - Observers
	
	func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.setTheme(_:)), name: .themeChangedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.handleOpenURL(_:)), name: .handleOpenURL, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.setContentSize(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
	}

	func handleOpenURL(_ notification:Notification){
    	if let url = notification.object as? String {
			let webURL = URL(string: url)

			#if DEBUG
				print("handleOpenURL. webURL=\(String(describing: webURL))")
			#endif
			
			handleOpenBrowser(webURL!, event: "handleOpenURL")
    	}
	}
	
	func setContentSize() {
		tableView.reloadData()
	}
	
	func setContentSize(_ notification: Notification) {
		#if DEBUG
            print("DetailViewController, Received UIContentSizeCategoryDidChangeNotification")
        #endif
		setContentSize()
	}
	
	func setTheme() {
		Theme.loadTheme()
		
		view.backgroundColor = Theme.backgroundColor
		tableView.backgroundColor = Theme.backgroundColor
		poweredLabel.textColor = Theme.poweredLabelColor
		searchBar.backgroundColor = Theme.backgroundColor
		searchBar.barStyle = Theme.barStyle
		
		// TODO: How to update the bar after changing
		// FIXME: Crashes with 3D Touch
		// self.navigationController!.navigationBar.backgroundColor = Theme.backgroundColor;
	}
	
//	override var preferredStatusBarStyle: UIStatusBarStyle {
//        return Theme.statusBarStyle
//    }
	
	func setTheme(_ notification: Notification) {
        #if DEBUG
            print("DetailViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	func setLoadingIndicator() {
		loadingIndicator.color = Theme.tintColor
   		loadingIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
   		loadingIndicator.center = self.view.center
   		self.view.addSubview(loadingIndicator)
   		loadingIndicator.bringSubview(toFront: self.view)
	}
	
	// MARK: - API
	
	func getNews(_ page: Int, forceRefresh: Bool, toTop: Bool = true) {
		if (!self.loading) {
			if !self.entries.isEmpty {
            	#if DEBUG
            	    print("DetailViewController, getNews: checking if entries need refreshing")
            	#endif
            
            	if let updated: Date = self.newsEntriesUpdatedByLang[self.settings.region] {
            	    let calendar = Calendar.current
            	    var comps = DateComponents()
            	    comps.minute = 1
            	    let updatedPlusMinute = (calendar as NSCalendar).date(byAdding: comps, to: updated, options: NSCalendar.Options())
            	    let today = Date()
                
            	    #if DEBUG
            	        print("DetailViewController, getNews: today=\(today), updated=\(updated), updatedPlusMinute=\(String(describing: updatedPlusMinute))")
            	    #endif
                
            	    if !forceRefresh && updatedPlusMinute!.isGreaterThanDate(today) {
						#if DEBUG
            	        	print("DetailViewController, getNews: No need for updating entries")
            	    	#endif
						self.refreshControl?.endRefreshing()
						self.setLoadingState(false)
            	        return
            	    }
            	}
        	}
		
			self.setLoadingState(true)
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.getNews(self.page, section: highFiSection,
				completionHandler:{ (result) in
					self.newsEntriesUpdatedByLang[self.settings.region] = Date()
                	#if DEBUG
                    	print("newsEntries updated, \(String(describing: self.newsEntriesUpdatedByLang[self.settings.region]))")
                	#endif
					self.setNews(result, toTop: toTop)
				}
				, failureHandler: {(error)in
					self.refreshControl?.endRefreshing()
					self.setLoadingState(false)
					self.handleError(error, title: self.errorTitle)
				}
			)
		}
	}
	
	func search(_ searchNews: String) {
		if (!self.loading) {
			self.setLoadingState(true)
			// with trailing closure we get the results that we passed the closure back in async function
			HighFiApi.search(searchNews, completionHandler:{ (result) in
					self.setSearchResults(result)
				}
				, failureHandler: {(error)in
					self.refreshControl?.endRefreshing()
					self.setLoadingState(false)
					self.handleError(error, title: self.errorTitle)
				}
			)
		}
	}
	
	func getFavorites() {
		if (!self.loading) {
			self.setLoadingState(true)
			if let categoriesFavorited = settings.categoriesFavorited[settings.region] {
				var filteredCategories = [Category]()
				self.settings.categories.forEach({ (category: Category) -> () in
					if categoriesFavorited.contains(category.sectionID) {
						filteredCategories.append(category)
					}
				})
				
				let getNewsGroup = DispatchGroup()
				var news = Dictionary<Int, Entry>()
				filteredCategories.forEach({(category: Category) -> () in
					getNewsGroup.enter()
				
					HighFiApi.getNews(1, section: category.htmlFilename,
						completionHandler: {(result) in
							result.forEach({(entry: Entry) -> () in
								news.updateValue(entry, forKey: entry.articleID)
							})
							getNewsGroup.leave()
						}
						, failureHandler: {(error)in
							self.refreshControl?.endRefreshing()
							self.setLoadingState(false)
							self.handleError(error, title: self.errorTitle)
							getNewsGroup.leave()
						}
					)
				})
			
				// called once all code blocks entered into group have left
    			getNewsGroup.notify(queue: DispatchQueue.main) {
					self.setNews(Array(news.values), toTop: true)
					news.removeAll(keepingCapacity: true)
				}
			} else {
				// TODO: do something?
			}
		}
	}
	
	func setNews(_ newsentries: Array<Entry>, toTop: Bool = true) {
		// Top items are not grouped by time
		if highFiSection == "top" {
			DispatchQueue.main.async {
				// Clear old entries
				self.entries = [Entry]()
				self.sections = OrderedDictionary<String, Array<Entry>>()
				self.sortedSections = [String]()
				self.entries = newsentries
				
				var i = 0
				var range = " 1 ..10"
				for item in self.entries {
					if (i < 10) {
						range = " 1 ..10"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else if (i < 20) {
						range = " 11 ..20"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else if (i < 30) {
						range = " 21 ..30"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else if (i < 40) {
						range = " 31 ..40"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else if (i < 50) {
						range = " 41 ..50"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else if (i < 60) {
						range = " 51 ..60"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else if (i < 70) {
						range = " 61 ..70"
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					} else {
						range = " 70 ..."
						self.sections[range] == nil ? self.sections[range] = [item] : self.sections[range]!.append(item)
					}
					
					self.sortedSections = self.sections.keys
					i += 1
				}
				
				self.tableView!.reloadData()
				self.refreshControl?.endRefreshing()
				self.setLoadingState(false)
				if toTop {
					self.scrollToTop()
				}
				
				return
			}
		} else {
			// Other categories are grouped by time
			for item in newsentries {
				item.timeSince = self.getTimeSince(item.publishedDateJS)
				item.orderNro = self.getOrder(item.publishedDateJS)
			}
			
			DispatchQueue.main.async {
				let fetchedEntries = newsentries.sorted { $0.orderNro < $1.orderNro }
				
				if self.page == 1 {
					// Clear old entries
					self.entries = [Entry]()
					self.sections = OrderedDictionary<String, Array<Entry>>()
					self.sortedSections = [String]()
					self.entries = fetchedEntries
				} else {
					self.entries = self.entries + fetchedEntries
				}
				
				// Put each item in a section
				for item in fetchedEntries {
					// If we don't have section for particular time, create new one,
					// Otherwise just add item to existing section
					if self.sections[item.timeSince] == nil {
						self.sections[item.timeSince] = [item]
					} else {
						self.sections[item.timeSince]!.append(item)
					}
					
					self.sortedSections = self.sections.keys
				}
				//self.sortedSections.sortInPlace{ $0 < $1 }
				
				self.tableView!.reloadData()
				self.refreshControl?.endRefreshing()
				self.setLoadingState(false)
				if self.page == 1 && toTop {
					self.scrollToTop()
				}
				
				return
			}
		}
	}
	
	func setSearchResults(_ newsentries: Array<Entry>) {
		for item in newsentries {
			item.timeSince = self.getTimeSince(item.publishedDateJS)
			item.orderNro = self.getOrder(item.publishedDateJS)
		}
			
		DispatchQueue.main.async {
			let fetchedEntries = newsentries.sorted { $0.orderNro < $1.orderNro }
				
			// Clear old entries
			self.entries = [Entry]()
			self.sections = OrderedDictionary<String, Array<Entry>>()
			self.sortedSections = [String]()
			self.entries = fetchedEntries
			
			// Put each item in a section
			for item in fetchedEntries {
				// If we don't have section for particular time, create new one,
				// Otherwise just add item to existing section
				if self.sections[item.timeSince] == nil {
					self.sections[item.timeSince] = [item]
				} else {
					self.sections[item.timeSince]!.append(item)
				}
				
				self.sortedSections = self.sections.keys
			}
			#if DEBUG
				print("filteredSections=\(self.sections.count)")
			#endif
			//self.sortedSections.sortInPlace{ $0 < $1 }

			self.tableView!.reloadData()
			self.refreshControl?.endRefreshing()
			self.setLoadingState(false)
			self.scrollToTop()
		
			return
		}
	}
	
	func configureTableView() {
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 110.0
	}
	
	func refresh(_ sender:AnyObject) {
		self.page = 1
		if (self.highFiSection == "favorites") {
			getFavorites()
		} else {
			getNews(self.page, forceRefresh: false)
		}
	}
	
	// MARK: - Functions
	
	func handleOpenBrowser(_ webURL: URL, title: String = "", event: String) {
		self.trackEvent(event, category: "ui_Event", action: event, label: "main", value: 1)
	
		if (settings.useChrome && OpenInChromeController.sharedInstance.isChromeInstalled()) {
			#if DEBUG
				print("isChromeInstalled=\(OpenInChromeController.sharedInstance.isChromeInstalled()), useChrome=\(settings.useChrome)")
			#endif
			_ = OpenInChromeController.sharedInstance.openInChrome(webURL, callbackURL: URL(string: "Highkara"), createNewTab: settings.createNewTab)
		} else {
			let svc = SFSafariViewController(url: webURL, entersReaderIfAvailable: settings.useReaderView)
			if #available(iOS 10.0, *) {
				svc.preferredControlTintColor  = Theme.tintColor
			} else {
				svc.view.tintColor = Theme.tintColor
			}
			self.present(svc, animated: true, completion: nil)
		}
	}
	
	func handleGesture(_ recognizer:UIScreenEdgePanGestureRecognizer) {
        self.animator.percentageDriven = true
		let percentComplete = recognizer.location(in: view).x / view.bounds.size.width
		
        switch recognizer.state {
        case .began: dismiss(animated: true, completion: nil)
        case .changed: animator.update(percentComplete > 0.99 ? 0.99 : percentComplete)
        case .ended, .cancelled:
            (recognizer.velocity(in: view).x < 0) ? animator.cancel() : animator.finish()
            self.animator.percentageDriven = false
        default: ()
        }
    }
	
	// MARK: - SafariView
	
	func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.dismissing = false
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.dismissing = true
        return animator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.percentageDriven ? self.animator : nil
    }
	
    // MARK: - Table view data source

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor

		var sectionLabel: UILabel
		if highFiSection != "top" {
			sectionLabel = UILabel(frame: CGRect(x: 25, y: 0, width: tableView.frame.size.width/2, height: 20))
		} else {
			sectionLabel = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width/2, height: 20))
		}
		sectionLabel.text = sortedSections[section]
		sectionLabel.textColor = Theme.sectionTitleColor
		sectionLabel.font = settings.fontSizeLarge

		clockLabel = UILabel(frame: CGRect(x: 8, y: 0, width: tableView.frame.size.width/2, height: 20))
		createClockIcon(Theme.textColor)

		if highFiSection != "top" {
			headerView.addSubview(clockLabel)
		}
		headerView.addSubview(sectionLabel)
		
    	return headerView
	}

	// MARK: - TableView
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let path = self.tableView!.indexPathForSelectedRow!
		let row = path.row
		
		let tableSection = sections[sortedSections[path.section]]
		let tableItem = tableSection![row]
		
		var webURL = URL(string: tableItem.originalURL)
		if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.settings.useMobileUrl) {
			webURL = URL(string: tableItem.originalMobileUrl!)
		}		
		#if DEBUG
			print("didSelectRowAtIndexPath, useMobileUrl=\(self.settings.useMobileUrl), useReaderView=\(self.settings.useReaderView)")
			print("didSelectRowAtIndexPath, webURL=\(String(describing: webURL))")
		#endif
		
		handleOpenBrowser(webURL!, title: tableItem.title, event: "openURL")
		
		self.trackNewsClick(tableItem)
	}
	
	// Return the number of sections
	func numberOfSections(in tableView: UITableView) -> Int {
		return self.sections.count
    }

	// Return the number of rows in the section.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.sections[sortedSections[section]]!.count
    }
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Configure the cell for this indexPath
		let cell: EntryCell! = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? EntryCell
		
		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
//		if(searchActive){
//			tableSection = filteredSections[filteredSectionsSorted[indexPath.section]]
//			tableItem = tableSection![indexPath.row]
//		}
		
		var date = ""
		// If published date is over one day, show date, otherwise time
		if tableItem.orderNro >= 1440 {
			date = formatDate(tableItem.publishedDateJS)
		} else {
			date = formatTime(tableItem.publishedDateJS)
		}
		
		cell.entryTitle.font = settings.fontSizeLarge
		cell.entryAuthor.font = settings.fontSizeSmall
		cell.entryDescription.font = settings.fontSizeMedium
		
		cell.entryTitle.text = tableItem.title
		cell.entryTitle.textColor = Theme.cellTitleColor
		cell.entryAuthor.text = tableItem.author + " - " + date
		cell.entryAuthor.textColor = Theme.cellAuthorColor
		if (tableItem.shortDescription != "" && settings.showDesc) {
			cell.entryDescription.text = tableItem.shortDescription
			cell.entryDescription.isHidden = false
		} else {
			cell.entryDescription.text = ""
			cell.entryDescription.isHidden = true
		}
		cell.entryDescription.textColor = Theme.cellDescriptionColor
		
		if settings.showNewsPicture {
			if tableItem.picture != nil {
				cell.entryImageWidthConstraint.constant = 100
        		cell.entryTitleLeadingConstraint.constant = 10
				cell.entryImage!.frame = CGRect(x: cell.entryImage!.frame.origin.x, y: cell.entryImage!.frame.origin.y, width: 100,height: 100)
				let downloadURL = URL(string: tableItem.picture!)!
				cell.configure(downloadURL)
			} else {
				cell.entryImage!.image = nil
				cell.entryImage.frame = CGRect.zero
				cell.entryImageWidthConstraint.constant = 0
        		cell.entryTitleLeadingConstraint.constant = 0
			}
		} else {
			cell.entryImage!.image = nil
			cell.entryImage.frame = CGRect.zero
			cell.entryImageWidthConstraint.constant = 0
        	cell.entryTitleLeadingConstraint.constant = 0
		}

		if tableItem.highlight == true {
			cell.entryTitle.isHighlighted = true
//			cell.entryTitle.highlightedTextColor = Theme.tintColor
		}
		
		cell.contentView.setNeedsLayout()
    	cell.contentView.layoutIfNeeded()

		cell.selectedBackgroundView = Theme.selectedCellBackground
		
		if (indexPath.row % 2 == 0) {
			cell.backgroundColor = Theme.evenRowColor
		} else {
			cell.backgroundColor = Theme.oddRowColor
		}
				
		Shared.hideWhiteSpaceBeforeCell(tableView, cell: cell)

        return cell
    }
	
//	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//	}
	
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
	
		let share = UITableViewRowAction(style: .default, title: shareButtonText) {
			(action: UITableViewRowAction, indexPath: IndexPath) -> Void in
			self.tableView(tableView, commit: UITableViewCellEditingStyle.none, forRowAt: indexPath)
			
			let tableSection = self.sections[self.sortedSections[indexPath.section]]
			let tableItem = tableSection![indexPath.row]
			
			var webURL = URL(string: tableItem.shareURL)
			if ((tableItem.mobileShareURL != nil && !tableItem.mobileShareURL!.isEmpty) && self.settings.useMobileUrl) {
				webURL = URL(string: tableItem.mobileShareURL!)
			}
			
			#if DEBUG
				print("shareAction, title=\(tableItem.title), webURL=\(String(describing: webURL))")
				print("shareAction, shareURL=\(tableItem.shareURL), mobileShareURL=\(String(describing: tableItem.mobileShareURL))")
			#endif
			
			self.trackEvent("shareAction", category: "ui_Event", action: "shareAction", label: "main", value: 1)
			
			let objectsToShare = [tableItem.title, webURL!] as [Any]
			let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
			
			self.present(activityViewController, animated: true, completion: nil)
		}
		share.backgroundColor = UIColor(red: 0.0/255, green: 171.0/255, blue: 132.0/255, alpha: 1)
		
		let delete = UITableViewRowAction(style: .default, title: deleteButtonText) {
			(action: UITableViewRowAction, indexPath: IndexPath) -> Void in
			let deleteAlert = UIAlertController(title: self.deleteButtonText, message: self.deleteAlertText, preferredStyle: UIAlertControllerStyle.alert)

			deleteAlert.addAction(UIAlertAction(title: self.deleteButtonText, style: .destructive, handler: { (action: UIAlertAction!) in
				self.tableView(tableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
			
				let tableSection = self.sections[self.sortedSections[indexPath.section]]
				let tableItem = tableSection![indexPath.row]
			
				#if DEBUG
					print("filter, author=\(tableItem.author), sourceId=\(tableItem.sourceID)")
				#endif
				
				self.trackEvent("removeSource", category: "ui_Event", action: "removeSource", label: "main", value: tableItem.sourceID as NSNumber)

				_ = self.settings.removeSource(tableItem.sourceID)
				
		        self.defaults!.set(self.settings.newsSourcesFiltered, forKey: "newsSourcesFiltered")
				self.defaults!.synchronize()
				
//				self.getNews(self.page, forceRefresh: true, toTop: false)
				
				self.tableView.isEditing = false
				deleteAlert.dismiss(animated: true, completion: nil)
			}))

			deleteAlert.addAction(UIAlertAction(title: self.cancelText, style: .cancel, handler: { (action: UIAlertAction!) in
				tableView.isEditing = false
				deleteAlert.dismiss(animated: true, completion: nil)
			}))
			
			self.present(deleteAlert, animated: true, completion: nil)
		}
		delete.backgroundColor = UIColor(red: 239.0/255, green: 51.0/255, blue: 64.0/255, alpha: 1)
		
		let browser = UITableViewRowAction(style: .default, title: browserButtonText) {
			(action: UITableViewRowAction, indexPath: IndexPath) -> Void in
			self.tableView(tableView, commit: UITableViewCellEditingStyle.insert, forRowAt: indexPath)
			
			let tableSection = self.sections[self.sortedSections[indexPath.section]]
			let tableItem = tableSection![indexPath.row]
			
			var webURL = URL(string: tableItem.originalURL)
			if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.settings.useMobileUrl) {
				webURL = URL(string: tableItem.originalMobileUrl!)
			}
			#if DEBUG
				print("browser, useMobileUrl=\(self.settings.useMobileUrl), useReaderView=\(self.settings.useReaderView)")
				print("browser, webURL=\(String(describing: webURL))")
			#endif
			
			self.trackEvent("externalBrowser", category: "ui_Event", action: "externalBrowser", label: "main", value: 1)
			
			// Open news item in external browser, like Safari
			UIApplication.shared.openURL(webURL!)
			
			self.trackNewsClick(tableItem)
		}
		browser.backgroundColor = UIColor.orange
		
		return [share, browser, delete]
	}
	
	// Enable swiping for showing action buttons
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	// We need empty implementation to get editActionsForRowAtIndexPath to work.
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
	}
	
	// MARK: - Helpers
	
	func formatTime(_ dateString: String) -> String {
		let date = dateFormatter.date(from: dateString)
		return publishedTimeFormatter.string(from: date!)
	}
	func formatDate(_ dateString: String) -> String {
		let date = dateFormatter.date(from: dateString)
		return publishedFormatter.string(from: date!)
	}

	func scrollToTop() {
		if (self.numberOfSections(in: self.tableView) > 0 ) {
			let top = IndexPath(row: Foundation.NSNotFound, section: 0);
			self.tableView.scrollToRow(at: top, at: UITableViewScrollPosition.top, animated: true);
		}
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Bottom, get next page
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
		if (maximumOffset - currentOffset) <= -80 {
			if (!self.loading && self.highFiSection != "top") {
				self.page += 1
				if (didSearch) {
					self.search(searchBar.text!)
				} else {
					self.getNews(page, forceRefresh: true)
				}
			}
		}
	}
	
	func setLoadingState(_ loading: Bool) {
		self.loading = loading
		self.loadingIndicator.isHidden = !loading
		if (loading) {
			self.loadingIndicator.startAnimating()
		} else {
			self.loadingIndicator.stopAnimating()
			self.loadingIndicator.hidesWhenStopped = true
		}
	}
	
	func getTimeSince(_ item: String) -> String {
		//println("getTimeSince: \(item)")
		if let startDate = dateFormatter.date(from: item) {
			let components = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: startDate, to: Date(), options: [])
			let days = components.day!
			let hours = components.hour!
			let minutes = components.minute
//			println("\(days) days, \(hours) hours, \(minutes) minutes")
			
			if days == 0 {
				if hours == 0 {
					if minutes < 0 { return NSLocalizedString("JUST_NOW", comment: "") }
					else if minutes < 5 { return NSLocalizedString("5_MIN", comment: "") }
					else if minutes < 15 { return NSLocalizedString("15_MIN", comment: "") }
					else if minutes < 30 { return NSLocalizedString("30_MIN", comment: "") }
					else if minutes < 45 { return NSLocalizedString("45_MIN", comment: "") }
					else if minutes < 60 { return NSLocalizedString("HOUR", comment: "") }
				} else {
					if hours == 1 {
						return String(format: NSLocalizedString("< %d hours", comment: ""), hours+1)
					} else {
						return String(format: NSLocalizedString("< %d hours", comment: ""), hours)
					}
				}
			} else {
				if days == 1 {
					return NSLocalizedString("YESTERDAY", comment: "")
				} else {
					return String(format: NSLocalizedString("%d days", comment: ""), days)
				}
			}
		}
		
		return NSLocalizedString("LONG_TIME", comment: "")
	}
	
	func getOrder(_ item: String) -> Int {
		if let startDate = dateFormatter.date(from: item) {
			let components = (calendar as NSCalendar).components([NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: startDate, to: Date(), options: [])
			let days = components.day!
			let hours = components.hour!
			let minutes = components.minute
			
			if days == 0 {
				if hours == 0 {
					if minutes < 0 { return 0 }
					else if minutes < 5 { return 5 }
					else if minutes < 15 { return 15 }
					else if minutes < 30 { return 30 }
					else if minutes < 45 { return 45 }
					else if minutes < 60 { return 60 }
				} else {
					if hours == 1 {
						return 60 * (hours + 1)
					} else {
						return 60 * hours
					}
				}
			} else {
				if days == 1 {
					return 1440
				} else {
					return 1440 * days
				}
			}
		}
		
		return 99999
	}
	
	func trackNewsClick(_ entry: Entry) {
		HighFiApi.trackNewsClick(entry.clickTrackingLink)
	}
	
	// MARK: - Icons
	
	func createClockIcon(_ color: UIColor) {
		let string = String.ionIconString("ion-ios-clock-outline")
        let stringAttributed = NSMutableAttributedString(string: string, attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue", size: 14.00)!])
        stringAttributed.addAttribute(NSFontAttributeName, value: UIFont.iconFontOfSize("ionicons", fontSize: 14), range: NSRange(location: 0,length: 1))
        stringAttributed.addAttribute(
        	NSForegroundColorAttributeName, value: color, range: NSRange(location: 0,length: 1)
        )
		clockLabel.attributedText = stringAttributed
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// stop observing
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DetailViewController: CategorySelectionDelegate {
	func categorySelected(_ newCategory: Category) {
		self.page = 1
		self.navigationItemTitle = newCategory.title
		self.navigationItem.title = self.navigationItemTitle
		self.highFiSection = newCategory.htmlFilename
		if newCategory.htmlFilename == "favorites" {
			getFavorites()
		} else {
			getNews(self.page, forceRefresh: true)
		}
	}
}
