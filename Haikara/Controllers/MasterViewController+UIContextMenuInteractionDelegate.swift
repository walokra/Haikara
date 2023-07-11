//
//  MasterViewController+UIViewControllerPreview.swift
//  highkara
//
//  The MIT License (MIT)
//
//  Copyright (c) 2023 Marko Wallin <mtw@iki.fi>
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
import SafariServices

extension MasterViewController {
    // MARK: UIContextMenuInteractionDelegate
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {

        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
              let _ = tableView.cellForRow(at: indexPath) else { return nil }
        
        // Create a detail view controller and set its properties.
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return nil }
        
        let selectedCategory = self.categories[indexPath.row]
        detailViewController.navigationItemTitle = selectedCategory.title
        detailViewController.highFiSection = selectedCategory.htmlFilename

//        /*
//            Set the height of the preview by setting the preferred content size of the detail view controller.
//            Width should be zero, because it's not used in portrait.
//        */
//        detailViewController.preferredContentSize = CGSize(width: 0.0, height: 0.0)
//
//        // Set the source rect to the cell frame, so surrounding elements are blurred.
//        previewingContext.sourceRect = cell.frame
        
        return UIContextMenuConfiguration(identifier: selectedCategory.title as NSCopying,
                previewProvider: { return detailViewController }, actionProvider: nil)
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
        willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        animator.preferredCommitStyle = .pop
        animator.addCompletion {
            if let vc = animator.previewViewController {
                self.show(vc, sender: self)
//                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
}
