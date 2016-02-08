//
//  MasterViewController+UIViewControllerPreview.swift
//  highkara
//
//  Created by Marko Wallin on 7.2.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit
import SafariServices

extension DetailViewController: UIViewControllerPreviewingDelegate {
    // MARK: UIViewControllerPreviewingDelegate
    
    /// Create a previewing view controller to be shown at "Peek".
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRowAtPoint(location),
                  cell = tableView.cellForRowAtIndexPath(indexPath) else { return nil }
		
		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
		let webURL = NSURL(string: tableItem.originalURL)
		
        // Create a detail view controller and set its properties.
        if #available(iOS 9.0, *) {
            let destinationViewController = SFSafariViewController(URL: webURL!, entersReaderIfAvailable: settings.useReaderView)

    	    destinationViewController.preferredContentSize = view.frame.size //CGSize(width: 0.0, height: 0.0)
        
	        // Set the source rect to the cell frame, so surrounding elements are blurred.
            previewingContext.sourceRect = cell.frame
        
        	return destinationViewController
		}
		return nil
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        showViewController(viewControllerToCommit, sender: self)
    }
}