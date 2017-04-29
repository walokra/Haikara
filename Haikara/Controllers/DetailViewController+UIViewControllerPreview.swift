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
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
                  let cell = tableView.cellForRow(at: indexPath) else { return nil }
		
		let tableSection = sections[sortedSections[indexPath.section]]
		let tableItem = tableSection![indexPath.row]
		let webURL = URL(string: tableItem.originalURL)
		
        // Create a detail view controller and set its properties.
		let destinationViewController = SFSafariViewController(url: webURL!, entersReaderIfAvailable: settings.useReaderView)

		destinationViewController.preferredContentSize = view.frame.size //CGSize(width: 0.0, height: 0.0)
        
		// Set the source rect to the cell frame, so surrounding elements are blurred.
		previewingContext.sourceRect = cell.frame
	
		return destinationViewController
    }
    
    /// Present the view controller for the "Pop" action.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Reuse the "Peek" view controller for presentation.
        show(viewControllerToCommit, sender: self)
    }
}
