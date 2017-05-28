//
//  Offer.swift
//  Terawhere
//
//  Created by Muhd Mirza on 3/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import Foundation

class Offer {
	var endAddr: String?
	var endLat: Double?
	var endLng: Double?
	var endName: String?
	
	var meetupTime: String?
	
	var startAddr: String?
	var startLat: Double?
	var startLng: Double?
	var startName: String?
	
	var remarks: String?
	var userId: String?
	var name: String?
	var offerId: Int?
	
	var vehicleDesc: String?
	var vehicleModel: String?
	var vehicleNumber: String?
	
	var status: Int?
	
	var createdDateString: String?
	var updatedDateString: String?
	var deletedDateString: String?
	
	var vacancy: Int?
	
	init() {
		
	}
	
	// to post
	init(forPostWithEndAddr endAddr: String?, endLat: Double?, endLng: Double?, endName: String?, meetupTime: String?, startAddr: String?, startLat: Double?, startLng: Double?, startName: String?, remarks: String?, userId: String?, vehicleDesc: String?, vehicleModel: String?, vehicleNumber: String?, status: Int?, vacancy: Int?) {
		self.endAddr = endAddr
		self.endLat = endLat
		self.endLng = endLng
		self.endName = endName
		
		self.meetupTime = meetupTime
		
		self.startAddr = startAddr
		self.startLat = startLat
		self.startLng = startLng
		self.startName = startName

		self.remarks = remarks
		self.userId = userId
		
		self.vehicleDesc = vehicleDesc
		self.vehicleModel = vehicleModel
		self.vehicleNumber = vehicleNumber
		
		self.status = status

		self.vacancy = vacancy
	}
	
	
	// to retrieve
	init(WithEndAddr endAddr: String?, endLat: Double?, endLng: Double?, endName: String?, meetupTime: String?, startAddr: String?, startLat: Double?, startLng: Double?, startName: String?, remarks: String?, userId: String?, name: String?, offerId: Int?, vehicleDesc: String?, vehicleModel: String?, vehicleNumber: String?, status: Int?, createdDateString: String?, updatedDateString: String?, deletedDateString: String?, vacancy: Int?) {
		self.endAddr = endAddr
		self.endLat = endLat
		self.endLng = endLng
		self.endName = endName
		
		self.meetupTime = meetupTime
		
		self.startAddr = startAddr
		self.startLat = startLat
		self.startLng = startLng
		self.startName = startName
		
		self.remarks = remarks
		self.userId = userId
		self.name = name
		self.offerId = offerId
		
		self.vehicleDesc = vehicleDesc
		self.vehicleModel = vehicleModel
		self.vehicleNumber = vehicleNumber
		
		self.status = status
		
		self.createdDateString = createdDateString
		self.updatedDateString = updatedDateString
		self.deletedDateString = deletedDateString
		
		self.vacancy = vacancy
	}
}
