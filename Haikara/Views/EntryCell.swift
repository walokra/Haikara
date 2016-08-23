//
//  EntryCell.swift
//  Haikara
//
//  Created by Marko Wallin on 27.6.2015.
//  Copyright (c) 2015 Rule of tech. All rights reserved.
//

import UIKit
import AlamofireImage

class EntryCell: UITableViewCell {


    @IBOutlet weak var entryTitle: UILabel!
    @IBOutlet weak var entryAuthor: UILabel!
    @IBOutlet weak var entryDescription: UILabel!
	@IBOutlet weak var entryImage: UIImageView!
	@IBOutlet weak var entryImageWidthConstraint: NSLayoutConstraint!
    
	@IBOutlet weak var entryTitleLeadingConstraint: NSLayoutConstraint!
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
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
