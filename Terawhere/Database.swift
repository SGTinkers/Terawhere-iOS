//
//  Database.swift
//  Terawhere
//
//  Created by Muhd Mirza on 3/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import Foundation
import MapKit

class Database {

	// treat this class as a setup class
	// no network calls done here
	// to avoid UI stuff from messing with database stuff

	var token = ""
	var userId = ""
	
	var authURL = "http://139.59.224.66/api/v1/auth"
	var allOffersURL = "http://139.59.224.66/api/v1/offers"
	var allOffersForUserURL = "http://139.59.224.66/api/v1/offers-for-user"
	var bookingURL = "http://139.59.224.66/api/v1/bookings"
	var allBookingsForUserURL = "http://139.59.224.66/api/v1/bookings-for-user"
	var allBookingsURL = "http://139.59.224.66/api/v1/bookings"
	
	var request: URLRequest?
	
	init() {
		print("This initializer is only for SignInViewController")
	}
	
	init(token: String?, userId: String?) {
		guard let token = token else {
			print("Token is not available")
			
			return
		}
		
		guard let userId = userId else {
			print("User Id is not available")
			
			return
		}
		
		self.token = token
		self.userId = userId
	}
	
	func getUserAuth() {
		let string = "token=\(self.token)"
		var data = string.data(using: .utf8)
		
		let string2 = "&service=facebook"
		let data2 = string2.data(using: .utf8)
		data?.append(data2!)
		
		let postData = NSMutableData(data: "token=\(self.token)".data(using: String.Encoding.utf8)!)
		postData.append("&service=facebook".data(using: String.Encoding.utf8)!)
		
		
		let url = URL.init(string: self.authURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		self.request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		self.request?.httpBody = postData as Data
	}
	
	func convertJSONToOffer(json: [String: Any?]) -> [Offer] {
		var offerArr = [Offer]()
		
		if let actualJsonData = json["data"] as? [[String: Any]] {
			for object in actualJsonData {
				let endAddr = object["end_addr"] as? String
				let endLat = object["end_lat"] as? Double
				let endLng = object["end_lng"] as? Double
				let endName = object["end_name"] as? String
				
				let meetupTime = object["meetup_time"] as? String
				
				let startAddr = object["start_addr"] as? String
				let startLat = object["start_lat"] as? Double
				let startLng = object["start_lng"] as? Double
				let startName = object["start_name"] as? String

				let remarks = object["remarks"] as? String
				let userId = object["user_id"] as? String
				let offerId = object["id"] as? Int
				
				let vehicleDesc = object["vehicle_desc"] as? String
				let vehicleModel = object["vehicle_model"] as? String
				let vehicleNumber = object["vehicle_number"] as? Int
				
				let status = object["status"] as? Int
				
				let createdDateString = object["created_at"] as? String
				let updatedDateString = object["updated_at"] as? String
				
				let vacancy = object["vacancy"] as? Int
				
				let offer = Offer.init(forRetrievewithEndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: meetupTime, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, remarks: remarks, userId: userId, offerId: offerId, vehicleDesc: vehicleDesc, vehicleModel: vehicleModel, vehicleNumber: vehicleNumber, status: status, createdDateString: createdDateString, updatedDateString: updatedDateString, vacancy: vacancy)
				
				offerArr.append(offer)
			}
		}
		
		return offerArr
	}

	
	func post(offer: Offer?) {
		guard let offer = offer else {
			print("Invalid offer")
			
			return
		}
		
		let json: [String: Any] = ["end_addr": offer.endAddr!,
		                           "end_lat": offer.endLat!,
		                           "end_lng": offer.endLng!,
		                           "end_name": offer.endName!,
		                           "meetup_time": offer.meetupTime!,
		                           "start_addr": offer.startAddr!,
		                           "start_lat": offer.startLat!,
		                           "start_lng": offer.startLng!,
		                           "start_name": offer.startName!,
								   "remarks": offer.remarks!,
								   "user_id": offer.userId!,
								   "vehicle_desc": offer.vehicleDesc!,
								   "vehicle_model": offer.vehicleModel!,
								   "vehicle_number": offer.vehicleNumber!,
								   "status": offer.status!,
		                           "vacancy": offer.vacancy!]

		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		let url = URL.init(string: "http://139.59.224.66/api/v1/offers")
		
		var request = URLRequest.init(url: url!)
		request.httpMethod = "POST"
		request.httpBody = jsonData
		
		print("Create offer token \(self.token)")
		
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
	}
	
	func getAllOffers() {
		//		guard let lat = self.userLocation?.coordinate.latitude else {
		//			print("User lat is unavailable")
		//
		//			return
		//		}
		//
		//		guard let lng = self.userLocation?.coordinate.longitude else {
		//			print("User lat is unavailable")
		//
		//			return
		//		}
		
		// guessing range is in meters
		//		let json: [String: Any] = ["lat": lat, "lng": lng, "range": 5000]
		//		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		
		let url = URL.init(string: self.allOffersURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func getAllOffersForUser() {
		let url = URL.init(string: self.allOffersForUserURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func deleteOfferBy(id: Int?) {
		let url = URL.init(string: "http://139.59.224.66/api/v1/offers/\(id!)")
		var request = URLRequest.init(url: url!)
		
		request.httpMethod = "DELETE"
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
				print(json!)
			}
		}
		
		task.resume()
	}
	
	func convertJSONToBooking(json: [String: Any?]) -> [Booking] {
		var bookingArr = [Booking]()
		
		if let actualJsonData = json["data"] as? [[String: Any]] {
			for object in actualJsonData {
				let offerId = object["offer_id"] as? Int
				
				let booking = Booking.init(offerId: offerId)
				bookingArr.append(booking)
			}
		}
		
		return bookingArr
	}
	
	func getAllBookings() {
		let url = URL.init(string: self.allBookingsURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
		print("Done with booking setup")
	}
	
	func book(offer: Offer) {
		let json: [String: Any] = ["offer_id": offer.offerId!]
		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
	
		let url = URL.init(string: self.bookingURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.httpMethod = "POST"
		self.request?.httpBody = jsonData
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
}
