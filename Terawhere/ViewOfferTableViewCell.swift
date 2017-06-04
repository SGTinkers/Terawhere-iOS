//
//  ViewOfferTableViewCell.swift
//  Terawhere
//
//  Created by Muhd Mirza on 5/6/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class ViewOfferTableViewCell: UITableViewCell {

	@IBOutlet var customTextLabel: UILabel!
	@IBOutlet var customDetailTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
