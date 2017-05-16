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
	
	var postOffersURL = "http://139.59.224.66/api/v1/offers"
	var allOffersURL = "http://139.59.224.66/api/v1/offers"
	var allOffersForUserURL = "http://139.59.224.66/api/v1/offers-for-user"
	var getSingleOfferURL = "http://139.59.224.66/api/v1/offers"
	var getAllBookingsForOffer = "http://139.59.224.66/api/v1/bookings-for-offer"
	var editOfferURL = "http://139.59.224.66/api/v1/offers"
	var deleteOfferURL = "http://139.59.224.66/api/v1/offers"
	
	var bookingURL = "http://139.59.224.66/api/v1/bookings"
	var allBookingsForUserURL = "http://139.59.224.66/api/v1/bookings-for-user"
	var allBookingsURL = "http://139.59.224.66/api/v1/bookings"
	var cancelBookingURL = "http://139.59.224.66/api/v1/bookings"
	
	
	var request: URLRequest?
	
	init() {
//		print("This initializer is only for SignInViewController")
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
		
		let postData = NSMutableData.init(data: data!)
		
//		let postData = NSMutableData(data: "token=\(self.token)".data(using: String.Encoding.utf8)!)
//		postData.append(string2.data(using: String.Encoding.utf8)!)
		
		
		let url = URL.init(string: self.authURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		self.request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		self.request?.httpBody = postData as Data
	}
	
	func convertJSONToOfferObject(json: [String: Any?]) -> Offer? {
		var offer: Offer?
	
		guard let actualJsonData = json["data"] as? [String: Any] else {
			print("actualJsonData invalid")
			
			return offer!
		}
		
		print("Actual json data \(actualJsonData)")
		
		let endAddr = actualJsonData["end_addr"] as? String
		let endLat = actualJsonData["end_lat"] as? Double
		let endLng = actualJsonData["end_lng"] as? Double
		let endName = actualJsonData["end_name"] as? String
		
		let meetupTime = actualJsonData["meetup_time"] as? String
		
		let startAddr = actualJsonData["start_addr"] as? String
		let startLat = actualJsonData["start_lat"] as? Double
		let startLng = actualJsonData["start_lng"] as? Double
		let startName = actualJsonData["start_name"] as? String
		
		let remarks = actualJsonData["remarks"] as? String
		let userId = actualJsonData["user_id"] as? String
		let name = actualJsonData["name"] as? String
		let offerId = actualJsonData["id"] as? Int
		
		let vehicleDesc = actualJsonData["vehicle_desc"] as? String
		let vehicleModel = actualJsonData["vehicle_model"] as? String
		let vehicleNumber = actualJsonData["vehicle_number"] as? String
		
		let status = actualJsonData["status"] as? Int
		
		let createdDateString = actualJsonData["created_at"] as? String
		let updatedDateString = actualJsonData["updated_at"] as? String
		
		let vacancy = actualJsonData["vacancy"] as? Int
		
		offer = Offer.init(forRetrievewithName: name, EndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: meetupTime, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, remarks: remarks, userId: userId, offerId: offerId, vehicleDesc: vehicleDesc, vehicleModel: vehicleModel, vehicleNumber: vehicleNumber, status: status, createdDateString: createdDateString, updatedDateString: updatedDateString, vacancy: vacancy)
		
		
		return offer
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
				let vehicleNumber = object["vehicle_number"] as? String
				
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
								   "vehicle_model": offer.vehicleModel!,
								   "vehicle_number": offer.vehicleNumber!,
		                           "vacancy": offer.vacancy!]

		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		let url = URL.init(string: self.postOffersURL)
		
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		self.request?.httpBody = jsonData

		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
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
	
	func get(offer: Offer?) {
		guard let offer = offer else {
			print("Offer is invalid")
			
			return
		}
		
		let getSingleOfferWithIdURL = self.getSingleOfferURL + "/\(offer.offerId!)"
		
		let url = URL.init(string: getSingleOfferWithIdURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func getOfferBy(id: Int?) {
		guard let id = id else {
			print("Offer is invalid")
			
			return
		}
		
		let getSingleOfferWithIdURL = self.getSingleOfferURL + "/\(id)"
		
		let url = URL.init(string: getSingleOfferWithIdURL)
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
	
	func edit(offer: Offer?) {
		guard let offer = offer else {
			print("Editing offer invalid")
			
			return
		}
	
		let editOfferWithIdURL = self.editOfferURL + "/\(offer.offerId!)"
	
		let dateFormatter = DateFormatter()
		
		dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		var dateString = ""
		
		// get the date object
		if let date = dateFormatter.date(from: offer.meetupTime!) {
			// setup a current time zone formatted dateFormatter
			dateFormatter.timeZone = TimeZone.autoupdatingCurrent
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
			// yyyy-MM-dd HH:mm
			
			// get the string
			dateString = dateFormatter.string(from: date)
		}
	
		
		let json: [String: Any] = ["end_addr": offer.endAddr!,
		                           "end_lat": offer.endLat!,
		                           "end_lng": offer.endLng!,
		                           "end_name": offer.endName!,
		                           "meetup_time": dateString,
		                           "start_addr": offer.startAddr!,
		                           "start_lat": offer.startLat!,
		                           "start_lng": offer.startLng!,
		                           "start_name": offer.startName!,
		                           "vehicle_model": offer.vehicleModel!,
		                           "vehicle_number": offer.vehicleNumber!,
		                           "vacancy": 1]
		
		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
	
	
		let url = URL.init(string: editOfferWithIdURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "PUT"
		self.request?.httpBody = jsonData!
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func delete(offer: Offer?) {
		guard let offer = offer else {
			print("Editing offer invalid")
			
			return
		}
	
		let deleteOfferWithIdURL = self.deleteOfferURL + "/\(offer.offerId!)"
		
		let url = URL.init(string: deleteOfferWithIdURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "DELETE"
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func convertJSONToBooking(json: [String: Any?]) -> [Booking] {
		var bookingArr = [Booking]()
		
		if let actualJsonData = json["data"] as? [[String: Any]] {
			for object in actualJsonData {
				let offerId = object["offer_id"] as? Int
				let id = object["id"] as? Int
				let paxBooked = object["pax"] as? Int
				let createdDate = object["created_at"] as? String
				let deletedDate = object["deleted_at"] as? String
				
				let booking = Booking.init(offerId: offerId, id: id, paxBooked: paxBooked, createdDate: createdDate, deletedDate: deletedDate)
				bookingArr.append(booking)
			}
		}
		
		return bookingArr
	}
	
	func getAllBookingsForUser() {
		let url = URL.init(string: self.allBookingsForUserURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func getAllBookingsForOfferByOffer(id: Int?) {
		let url = URL.init(string: self.getAllBookingsForOffer)
		self.request = URLRequest.init(url: url!)
		
		let json: [String: Any] = ["offer_id": id!]
		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		
		self.request?.httpBody = jsonData
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
	
	func cancel(booking: Booking?) {
		guard let booking = booking else {
			print("Booking is invalid")
			
			return
		}
	
		let cancelBookingWithIdURL = self.cancelBookingURL + "/\(booking.id!)"
	
		let url = URL.init(string: cancelBookingWithIdURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.httpMethod = "DELETE"
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
}
