//
//  BookingTableViewCell.swift
//  Terawhere
//
//  Created by Muhd Mirza on 6/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class BookingsTableViewCell: UITableViewCell {
	
	@IBOutlet var customView: UIView!
	@IBOutlet var title: UILabel!
	
	var booking: Booking? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		self.customView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}