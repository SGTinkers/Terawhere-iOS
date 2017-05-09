//
//  Offer.swift
//  Terawhere
//
//  Created by Muhd Mirza on 3/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import Foundation

class Offer {
	let endAddr: String?
	let endLat: Double?
	let endLng: Double?
	let endName: String?
	
	let meetupTime: String?
	
	let startAddr: String?
	let startLat: Double?
	let startLng: Double?
	let startName: String?
	
	let vacancy: Int?
	
	init(withEndAddr endAddr: String?, endLat: Double?, endLng: Double?, endName: String?, meetupTime: String?, startAddr: String?, startLat: Double?, startLng: Double?, startName: String?, vacancy: Int?) {
		self.endAddr = endAddr
		self.endLat = endLat
		self.endLng = endLng
		self.endName = endName
		
		self.meetupTime = meetupTime
		
		self.startAddr = startAddr
		self.startLat = startLat
		self.startLng = startLng
		self.startName = startName

		self.vacancy = vacancy
	}
}
