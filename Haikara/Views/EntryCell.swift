//
//  EntryCell.swift
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
import Alamofire
import AlamofireImage

class EntryCell: UITableViewCell {


    @IBOutlet weak var entryTitle: UILabel!
    @IBOutlet weak var entryAuthor: UILabel!
    @IBOutlet weak var entryDescription: UILabel!
   	@IBOutlet weak var entryImage: UIImageView!
	@IBOutlet weak var entryImageWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var entryTitleLeadingConstraint: NSLayoutConstraint!

	var request: Request?

	func configure(_ downloadURL: URL) {
        reset()
		populateCell(downloadURL)
    }

	func reset() {
        entryImage.image = nil
        request?.cancel()
    }

    func populateCell(_ downloadURL: URL) {
		entryImage!.af_setImage(
					withURL: downloadURL,
					placeholderImage: UIImage(named: "PlaceholderImage"),
					filter: nil)
    }
	
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ hilighted: Bool, animated: Bool) {
        super.setHighlighted(hilighted, animated: animated)
        
        // Configure the view for the hilighted state
    }
}
