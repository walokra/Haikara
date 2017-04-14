//
//  TodayEntryCell.swift
//  highkara
//
//  Created by Marko Wallin on 20.6.2016.
//  Copyright © 2016 Rule of tech. All rights reserved.
//

import UIKit

class TodayEntryCell: UITableViewCell {

	@IBOutlet weak var entryTitle: UILabel!
	
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
}

