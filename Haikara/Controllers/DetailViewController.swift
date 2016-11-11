//
//  ViewController.swift
//  Haikara
//
//  Created by Marko Wallin on 15.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController, SFSafariViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UISearchBarDelegate {

    let animator = SCModalPushPopAnimator()
	
	let viewName = "MainView"

	@IBOutlet weak var searchBar: UISearchBar!
	var searchActive : Bool = false
	
//	var filtered:[Entry] = []
//	var filteredSections = OrderedDictionary<String, Array<Entry>>()
//	var filteredSectionsSorted = [String]()

	let cellIdentifier = "tableCell"
	var entries = [Entry]()
	var newsEntriesUpdatedByLang = Dictionary<String, NSDate>()
	
	let settings = Settings.sharedInstance
	var defaults: NSUserDefaults?
	
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

	let calendar = NSCalendar.autoupdatingCurrentCalendar()
	let dateFormatter = NSDateFormatter()
	let publishedFormatter = NSDateFormatter()
	let publishedTimeFormatter = NSDateFormatter()
	
	let loadingIndicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
	var loading = false
	
	// Icons
	var clockLabel: UILabel!

	// MARK: Search
	func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
		self.title = self.navigationItemTitle
		getNews(1, forceRefresh: true)
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
		self.search(searchBar.text!)
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		searchActive = true
//		self.title = searchText
		self.title = searchTitle
    }

	// MARK: Lifecycle

    override func viewDidLoad() {
		#if DEBUG
			print("viewDidLoad()")
		#endif
        super.viewDidLoad()
		
		self.defaults = settings.defaults
		
		// Check for force touch feature, and add force touch/previewing capability.
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                registerForPreviewingWithDelegate(self, sourceView: tableView)
            }
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
    	let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
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
		
		var localTimeZone: String { return NSTimeZone.localTimeZone().abbreviation ?? "" }

		dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000'Z'"
		publishedFormatter.timeZone = NSTimeZone(abbreviation: localTimeZone)
		publishedFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
		publishedTimeFormatter.timeZone = NSTimeZone(abbreviation: localTimeZone)
		publishedTimeFormatter.dateFormat = "HH:mm"
		
		// self.tableFooter.hidden = true
	
		self.page = 1
		getNews(self.page, forceRefresh: true)
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("REFRESH", comment: "Refresh the news"))
		self.refreshControl.addTarget(self, action: #selector(DetailViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)
	}
	
	// MARK: - Observers
	
	func setObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.setTheme(_:)), name: "themeChangedNotification", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.handleOpenURL(_:)), name:"handleOpenURL", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.setContentSize(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
	}

	func handleOpenURL(notification:NSNotification){
    	if let url = notification.object as? String {
			let webURL = NSURL(string: url)

			#if DEBUG
				print("handleOpenURL. webURL=\(webURL)")
			#endif
			
			handleOpenBrowser(webURL!, event: "handleOpenURL")
    	}
	}
	
	func setContentSize() {
		tableView.reloadData()
	}
	
	func setContentSize(notification: NSNotification) {
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
	
	func setTheme(notification: NSNotification) {
        #if DEBUG
            print("DetailViewController, Received themeChangedNotification")
        #endif
		setTheme()
	}
	
	func setLoadingIndicator() {
		loadingIndicator.color = Theme.tintColor
   		loadingIndicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
   		loadingIndicator.center = self.view.center
   		self.view.addSubview(loadingIndicator)
   		loadingIndicator.bringSubviewToFront(self.view)
	}
	
	// MARK: - API
	
	func getNews(page: Int, forceRefresh: Bool, toTop: Bool = true) {
		if (!self.loading) {
			if !self.entries.isEmpty {
            	#if DEBUG
            	    print("DetailViewController, getNews: checking if entries need refreshing")
            	#endif
            
            	if let updated: NSDate = self.newsEntriesUpdatedByLang[self.settings.region] {
            	    let calendar = NSCalendar.currentCalendar()
            	    let comps = NSDateComponents()
            	    comps.minute = 1
            	    let updatedPlusMinute = calendar.dateByAddingComponents(comps, toDate: updated, options: NSCalendarOptions())
            	    let today = NSDate()
                
            	    #if DEBUG
            	        print("DetailViewController, getNews: today=\(today), updated=\(updated), updatedPlusMinute=\(updatedPlusMinute)")
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
					self.newsEntriesUpdatedByLang[self.settings.region] = NSDate()
                	#if DEBUG
                    	print("newsEntries updated, \(self.newsEntriesUpdatedByLang[self.settings.region])")
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
	
	func search(searchNews: String) {
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
				
				let getNewsGroup = dispatch_group_create()
				var news = Dictionary<Int, Entry>()
				filteredCategories.forEach({(category: Category) -> () in
					dispatch_group_enter(getNewsGroup)
				
					HighFiApi.getNews(1, section: category.htmlFilename,
						completionHandler: {(result) in
							result.forEach({(entry: Entry) -> () in
								news.updateValue(entry, forKey: entry.articleID)
							})
							dispatch_group_leave(getNewsGroup)
						}
						, failureHandler: {(error)in
							self.refreshControl?.endRefreshing()
							self.setLoadingState(false)
							self.handleError(error, title: self.errorTitle)
							dispatch_group_leave(getNewsGroup)
						}
					)
				})
			
				// called once all code blocks entered into group have left
    			dispatch_group_notify(getNewsGroup, dispatch_get_main_queue()) {
					self.setNews(Array(news.values), toTop: true)
					news.removeAll(keepCapacity: true)
				}
			} else {
				// TODO: do something?
			}
		}
	}
	
	func setNews(newsentries: Array<Entry>, toTop: Bool = true) {
		// Top items are not grouped by time
		if highFiSection == "top" {
			dispatch_async(dispatch_get_main_queue()) {
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
				//println("sections=\(self.sections.count)")
				
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
			
			dispatch_async(dispatch_get_main_queue()) {
				let fetchedEntries = newsentries.sort { $0.orderNro < $1.orderNro }
				
				if self.page == 1 {
					// Clear old entries
					self.entries = [Entry]()
					self.sections = OrderedDictionary<String, Array<Entry>>()
					self.sortedSections = [String]()
					self.entries = fetchedEntries
				} else {
					self.entries = self.entries + fetchedEntries
				}
				//println("newsEntries=\(self.newsEntries.count)")
				
				// Put each item in a section
				for item in fetchedEntries {
					// If we don't have section for particular time, create new one,
					// Otherwise just add item to existing section
					//	println("section=\(entry.section), title=\(entry.title)")
					if self.sections[item.timeSince] == nil {
						self.sections[item.timeSince] = [item]
					} else {
						self.sections[item.timeSince]!.append(item)
					}
					
					self.sortedSections = self.sections.keys
				}
				//println("sections=\(self.sections.count)")
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
	
	func setSearchResults(newsentries: Array<Entry>) {
		for item in newsentries {
			item.timeSince = self.getTimeSince(item.publishedDateJS)
			item.orderNro = self.getOrder(item.publishedDateJS)
		}
			
		dispatch_async(dispatch_get_main_queue()) {
			let fetchedEntries = newsentries.sort { $0.orderNro < $1.orderNro }
				
			// Clear old entries
			self.entries = [Entry]()
			self.sections = OrderedDictionary<String, Array<Entry>>()
			self.sortedSections = [String]()
			self.entries = fetchedEntries
			
			// Put each item in a section
			for item in fetchedEntries {
				// If we don't have section for particular time, create new one,
				// Otherwise just add item to existing section
				//	println("section=\(entry.section), title=\(entry.title)")
				if self.sections[item.timeSince] == nil {
					self.sections[item.timeSince] = [item]
				} else {
					self.sections[item.timeSince]!.append(item)
				}
				
				self.sortedSections = self.sections.keys
			}
			print("filteredSections=\(self.sections.count)")
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
	
	func refresh(sender:AnyObject) {
		self.page = 1
		if (self.highFiSection == "favorites") {
			getFavorites()
		} else {
			getNews(self.page, forceRefresh: false)
		}
	}
	
	// MARK: - Functions
	
	func handleOpenBrowser(webURL: NSURL, title: String = "", event: String) {
		self.trackEvent(event, category: "ui_Event", action: event, label: "main", value: 1)
	
		if (settings.useChrome && OpenInChromeController.sharedInstance.isChromeInstalled()) {
			#if DEBUG
				print("isChromeInstalled=\(OpenInChromeController.sharedInstance.isChromeInstalled()), useChrome=\(settings.useChrome)")
			#endif
			OpenInChromeController.sharedInstance.openInChrome(webURL, createNewTab: settings.createNewTab, callbackURL: NSURL(string: "Highkara"))
		} else {
			if #available(iOS 9.0, *) {
				#if DEBUG
					print("iOS 9.0, *")
				#endif
				let svc = SFSafariViewController(URL: webURL, entersReaderIfAvailable: settings.useReaderView)
				svc.view.tintColor = Theme.tintColor
				self.presentViewController(svc, animated: true, completion: nil)
			} else {
				#if DEBUG
					print("Fallback on earlier versions")
				#endif

				let vc = NewsItemViewController()
				if (!title.isEmpty) {vc.title = title}
				vc.loadWebView(webURL)
				self.navigationController?.pushViewController(vc, animated: true)
			}
		}
	}
	
	func handleGesture(recognizer:UIScreenEdgePanGestureRecognizer) {
        self.animator.percentageDriven = true
		let percentComplete = recognizer.locationInView(view).x / view.bounds.size.width
		
        switch recognizer.state {
        case .Began: dismissViewControllerAnimated(true, completion: nil)
        case .Changed: animator.updateInteractiveTransition(percentComplete > 0.99 ? 0.99 : percentComplete)
        case .Ended, .Cancelled:
            (recognizer.velocityInView(view).x < 0) ? animator.cancelInteractiveTransition() : animator.finishInteractiveTransition()
            self.animator.percentageDriven = false
        default: ()
        }
    }
	
	// MARK: - SafariView
	
	// Dismiss the view controller and return to app.
	@available(iOS 9.0, *)
	func safariViewControllerDidFinish(controller: SFSafariViewController) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.dismissing = false
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.dismissing = true
        return animator
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.percentageDriven ? self.animator : nil
    }
	
    // MARK: - Table view data source

	func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
	    let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
		headerView.tintColor = Theme.sectionColor
		headerView.backgroundColor = Theme.sectionColor

		var sectionLabel: UILabel
		if highFiSection != "top" {
			sectionLabel = UILabel(frame: CGRectMake(25, 0, tableView.frame.size.width/2, 20))
		} else {
			sectionLabel = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width/2, 20))
		}
		sectionLabel.text = sortedSections[section]
		sectionLabel.textColor = Theme.sectionTitleColor
		sectionLabel.font = settings.fontSizeLarge

		clockLabel = UILabel(frame: CGRectMake(8, 0, tableView.frame.size.width/2, 20))
		createClockIcon(Theme.textColor)

		if highFiSection != "top" {
			headerView.addSubview(clockLabel)
		}
		headerView.addSubview(sectionLabel)
		
    	return headerView
	}

	// MARK: - TableView
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let path = self.tableView!.indexPathForSelectedRow!
		let row = path.row
		
		let tableSection = sections[sortedSections[path.section]]
		let tableItem = tableSection![row]
		
		var webURL = NSURL(string: tableItem.originalURL)
		if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.settings.useMobileUrl) {
			webURL = NSURL(string: tableItem.originalMobileUrl!)
		}		
		#if DEBUG
			print("didSelectRowAtIndexPath, useMobileUrl=\(self.settings.useMobileUrl), useReaderView=\(self.settings.useReaderView)")
			print("didSelectRowAtIndexPath, webURL=\(webURL)")
		#endif
		
		handleOpenBrowser(webURL!, title: tableItem.title, event: "openURL")
		
		self.trackNewsClick(tableItem)
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//		if(searchActive) {
//            return filteredSections.count
//        }
        // Return the number of sections.
		return self.sections.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
//		if(searchActive){
//			return self.filteredSections[filteredSectionsSorted[section]]!.count
//		}
		return self.sections[sortedSections[section]]!.count
    }
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		// Configure the cell for this indexPath
		let cell: EntryCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as? EntryCell
		
		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
//		if(searchActive){
//			tableSection = filteredSections[filteredSectionsSorted[indexPath.section]]
//			tableItem = tableSection![indexPath.row]
//		}
		
		var date = ""
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
			cell.entryDescription.hidden = false
		} else {
			cell.entryDescription.text = ""
			cell.entryDescription.hidden = true
		}
		cell.entryDescription.textColor = Theme.cellDescriptionColor
		
		if settings.showNewsPicture {
			if tableItem.picture != nil {
				cell.entryImageWidthConstraint.constant = 100
        		cell.entryTitleLeadingConstraint.constant = 10
				cell.entryImage!.frame = CGRect(x: cell.entryImage!.frame.origin.x, y: cell.entryImage!.frame.origin.y, width: 100,height: 100)
				let downloadURL = NSURL(string: tableItem.picture!)!
				cell.entryImage!.af_setImageWithURL(
					downloadURL,
					placeholderImage: nil,
					filter: nil,
					imageTransition: .None)
			} else {
				cell.entryImage!.image = nil
				cell.entryImage.frame = CGRectZero
				cell.entryImageWidthConstraint.constant = 0
        		cell.entryTitleLeadingConstraint.constant = 0
			}
		} else {
			cell.entryImage!.image = nil
			cell.entryImage.frame = CGRectZero
			cell.entryImageWidthConstraint.constant = 0
        	cell.entryTitleLeadingConstraint.constant = 0
		}

		if tableItem.highlight == true {
			cell.entryTitle.highlighted = true
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
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
	
		let share = UITableViewRowAction(style: .Default, title: shareButtonText) {
			(action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
			self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.None, forRowAtIndexPath: indexPath)
			
			let tableSection = self.sections[self.sortedSections[indexPath.section]]
			let tableItem = tableSection![indexPath.row]
			
			var webURL = NSURL(string: tableItem.shareURL)
			if ((tableItem.mobileShareURL != nil && !tableItem.mobileShareURL!.isEmpty) && self.settings.useMobileUrl) {
				webURL = NSURL(string: tableItem.mobileShareURL!)
			}
			
			#if DEBUG
				print("shareAction, title=\(tableItem.title), webURL=\(webURL)")
				print("shareAction, shareURL=\(tableItem.shareURL), mobileShareURL=\(tableItem.mobileShareURL)")
			#endif
			
			self.trackEvent("shareAction", category: "ui_Event", action: "shareAction", label: "main", value: 1)
			
			let objectsToShare = [tableItem.title, webURL!]
			let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
			
			activityViewController.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
			
			self.presentViewController(activityViewController, animated: true, completion: nil)
		}
		share.backgroundColor = UIColor(red: 0.0/255, green: 171.0/255, blue: 132.0/255, alpha: 1)
		
		let delete = UITableViewRowAction(style: .Default, title: deleteButtonText) {
			(action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
			let deleteAlert = UIAlertController(title: self.deleteButtonText, message: self.deleteAlertText, preferredStyle: UIAlertControllerStyle.Alert)

			deleteAlert.addAction(UIAlertAction(title: self.deleteButtonText, style: .Destructive, handler: { (action: UIAlertAction!) in
				self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
			
				let tableSection = self.sections[self.sortedSections[indexPath.section]]
				let tableItem = tableSection![indexPath.row]
			
				#if DEBUG
					print("filter, author=\(tableItem.author), sourceId=\(tableItem.sourceID)")
				#endif
				
				self.trackEvent("removeSource", category: "ui_Event", action: "removeSource", label: "main", value: tableItem.sourceID)

				self.settings.removeSource(tableItem.sourceID)
				
		        self.defaults!.setObject(self.settings.newsSourcesFiltered, forKey: "newsSourcesFiltered")
				self.defaults!.synchronize()
				
//				self.getNews(self.page, forceRefresh: true, toTop: false)
				
				self.tableView.editing = false
				deleteAlert.dismissViewControllerAnimated(true, completion: nil)
			}))

			deleteAlert.addAction(UIAlertAction(title: self.cancelText, style: .Cancel, handler: { (action: UIAlertAction!) in
				tableView.editing = false
				deleteAlert.dismissViewControllerAnimated(true, completion: nil)
			}))
			
			self.presentViewController(deleteAlert, animated: true, completion: nil)
		}
		delete.backgroundColor = UIColor(red: 239.0/255, green: 51.0/255, blue: 64.0/255, alpha: 1)
		
		let browser = UITableViewRowAction(style: .Default, title: browserButtonText) {
			(action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
			self.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: indexPath)
			
			let tableSection = self.sections[self.sortedSections[indexPath.section]]
			let tableItem = tableSection![indexPath.row]
			
			var webURL = NSURL(string: tableItem.originalURL)
			if ((tableItem.originalMobileUrl != nil && !tableItem.originalMobileUrl!.isEmpty) && self.settings.useMobileUrl) {
				webURL = NSURL(string: tableItem.originalMobileUrl!)
			}
			#if DEBUG
				print("browser, useMobileUrl=\(self.settings.useMobileUrl), useReaderView=\(self.settings.useReaderView)")
				print("browser, webURL=\(webURL)")
			#endif
			
			self.trackEvent("externalBrowser", category: "ui_Event", action: "externalBrowser", label: "main", value: 1)
			
			// Open news item in external browser, like Safari
			UIApplication.sharedApplication().openURL(webURL!)
			
			self.trackNewsClick(tableItem)
		}
		browser.backgroundColor = UIColor.orangeColor()
		
		return [share, browser, delete]
	}
	
	// Enable swiping for showing action buttons
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	// We need empty implementation to get editActionsForRowAtIndexPath to work.
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}
	
	// MARK: - Helpers
	
	func formatTime(dateString: String) -> String {
		let date = dateFormatter.dateFromString(dateString)
		return publishedTimeFormatter.stringFromDate(date!)
	}
	func formatDate(dateString: String) -> String {
		let date = dateFormatter.dateFromString(dateString)
		return publishedFormatter.stringFromDate(date!)
	}

	func scrollToTop() {
		if (self.numberOfSectionsInTableView(self.tableView) > 0 ) {
			let top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
			self.tableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
		}
	}
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		// Bottom, get next page
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//		print("scrollViewDidScroll, currentOffset=\(currentOffset), maximumOffset=\(maximumOffset), diff=\(maximumOffset - currentOffset)")
		if (maximumOffset - currentOffset) <= -80 {
			if (!self.loading && self.highFiSection != "top") {
				self.page += 1
				self.getNews(page, forceRefresh: true)
			}
		}
	}
	
	func setLoadingState(loading: Bool) {
		self.loading = loading
		self.loadingIndicator.hidden = !loading
		if (loading) {
			self.loadingIndicator.startAnimating()
		} else {
			self.loadingIndicator.stopAnimating()
			self.loadingIndicator.hidesWhenStopped = true
		}
	}
	
	func getTimeSince(item: String) -> String {
		//println("getTimeSince: \(item)")
		if let startDate = dateFormatter.dateFromString(item) {
			let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: startDate, toDate: NSDate(), options: [])
			let days = components.day
			let hours = components.hour
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
	
	func getOrder(item: String) -> Int {
		if let startDate = dateFormatter.dateFromString(item) {
			let components = calendar.components([NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: startDate, toDate: NSDate(), options: [])
			let days = components.day
			let hours = components.hour
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
	
	func trackNewsClick(entry: Entry) {
		HighFiApi.trackNewsClick(entry.clickTrackingLink)
	}
	
	// MARK: - Icons
	
	func createClockIcon(color: UIColor) {
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension DetailViewController: CategorySelectionDelegate {
	func categorySelected(newCategory: Category) {
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
