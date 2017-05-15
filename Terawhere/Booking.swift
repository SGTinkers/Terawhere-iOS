//
//  Booking.swift
//  Terawhere
//
//  Created by Muhd Mirza on 6/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import Foundation

class Booking {
	let offerId: Int?
	let id: Int?
	let paxBooked: Int?
	let createdDate: String?
	let deletedDate: String?
	
	init(offerId: Int?, id: Int?, paxBooked: Int?, createdDate: String?, deletedDate: String?) {
		self.offerId = offerId
		self.id = id
		self.paxBooked = paxBooked
		self.createdDate = createdDate
		self.deletedDate = deletedDate
	}
}
