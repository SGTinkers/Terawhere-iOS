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
	
	let remarks: String?
	let userId: String?
	var offerId: Int? = nil
	
	let vehicleDesc: String?
	let vehicleModel: String?
	let vehicleNumber: Int?
	
	let status: Int?
	
	var createdDateString: String? = nil
	var updatedDateString: String? = nil
	
	let vacancy: Int?
	
	// to post
	init(forPostWithEndAddr endAddr: String?, endLat: Double?, endLng: Double?, endName: String?, meetupTime: String?, startAddr: String?, startLat: Double?, startLng: Double?, startName: String?, remarks: String?, userId: String?, vehicleDesc: String?, vehicleModel: String?, vehicleNumber: Int?, status: Int?, vacancy: Int?) {
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
	init(forRetrievewithEndAddr endAddr: String?, endLat: Double?, endLng: Double?, endName: String?, meetupTime: String?, startAddr: String?, startLat: Double?, startLng: Double?, startName: String?, remarks: String?, userId: String?, offerId: Int?, vehicleDesc: String?, vehicleModel: String?, vehicleNumber: Int?, status: Int?, createdDateString: String?, updatedDateString: String?, vacancy: Int?) {
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
		self.offerId = offerId
		
		self.vehicleDesc = vehicleDesc
		self.vehicleModel = vehicleModel
		self.vehicleNumber = vehicleNumber
		
		self.status = status
		
		self.createdDateString = createdDateString
		self.updatedDateString = updatedDateString
		
		self.vacancy = vacancy
	}
}
