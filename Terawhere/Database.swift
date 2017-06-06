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

    static let serverBaseUrl = "http://139.59.224.66" // dev
//    static let serverBaseUrl = "https://api.terawhere.com" // prod
    
	// treat this class as a setup class
	// no network calls done here
	// to avoid UI stuff from messing with database stuff
	var token = ""
	var userId = ""

	var authURL = serverBaseUrl + "/api/v1/auth"
	var refreshTokenURL = serverBaseUrl + "/api/v1/auth/refresh"
	
	var postOffersURL = serverBaseUrl + "/api/v1/offers"
	
	var nearbyOffersURL = serverBaseUrl + "/api/v1/nearby-offers"
	var allOffersForUserURL = serverBaseUrl + "/api/v1/users/me/offers"
	var getSingleOfferURL = serverBaseUrl + "/api/v1/offers"
	var getAllBookingsForOffer = serverBaseUrl + "/api/v1/offers"
	var editOfferURL = serverBaseUrl + "/api/v1/offers"
	var deleteOfferURL = serverBaseUrl + "/api/v1/offers"
	
	var bookingURL = serverBaseUrl + "/api/v1/bookings"
	var allBookingsForUserURL = serverBaseUrl + "/api/v1/users/me/bookings"
	var cancelBookingURL = serverBaseUrl + "/api/v1/bookings"
	
	var notifURL = serverBaseUrl + "/api/v1/devices"
	
	
	var request: URLRequest?
	
	init() {

	}
	
	// MARK: Auth and tokens
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
		let token = "token=\(self.token)"
		let service = "&service=facebook"
		
		let postData = NSMutableData(data: token.data(using: String.Encoding.utf8)!)
		postData.append(service.data(using: String.Encoding.utf8)!)
		
		
		let url = URL.init(string: self.authURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		self.request?.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		self.request?.httpBody = postData as Data
	}
	
	func refreshToken() {
		let url = URL.init(string: self.refreshTokenURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
	}
	
	func sendNotif(token: String) {
		let json: [String: Any] = ["device_token": token, "platform": "ios"]
		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
	
		let url = URL.init(string: self.notifURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		self.request?.httpBody = jsonData!
		
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
	}
	
	// MARK: Conversions
	func convertJSONToOfferObject(json: [String: Any?]) -> Offer? {
		var offer: Offer?
	
		guard let actualJsonData = json["data"] as? [String: Any] else {
			print("actualJsonData invalid")
			
			return offer
		}

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
		let deletedDateString = actualJsonData["deleted_at"] as? String
		
		let vacancy = actualJsonData["vacancy"] as? Int
		
		offer = Offer.init(WithEndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: meetupTime, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, remarks: remarks, userId: userId, name: name, offerId: offerId, vehicleDesc: vehicleDesc, vehicleModel: vehicleModel, vehicleNumber: vehicleNumber, status: status, createdDateString: createdDateString, updatedDateString: updatedDateString, deletedDateString: deletedDateString, vacancy: vacancy)
		
		
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
				let name = object["name"] as? String
				let offerId = object["id"] as? Int
				
				let vehicleDesc = object["vehicle_desc"] as? String
				let vehicleModel = object["vehicle_model"] as? String
				let vehicleNumber = object["vehicle_number"] as? String
				
				let status = object["status"] as? Int
				
				let createdDateString = object["created_at"] as? String
				let updatedDateString = object["updated_at"] as? String
				let deletedDateString = object["deleted_at"] as? String
				
				let vacancy = object["vacancy"] as? Int
				
				let offer = Offer.init(WithEndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: meetupTime, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, remarks: remarks, userId: userId, name: name, offerId: offerId, vehicleDesc: vehicleDesc, vehicleModel: vehicleModel, vehicleNumber: vehicleNumber, status: status, createdDateString: createdDateString, updatedDateString: updatedDateString, deletedDateString: deletedDateString, vacancy: vacancy)
				
				offerArr.append(offer)
			}
		}
		
		return offerArr
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
	
	// MARK: Offers
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
								   "vehicle_desc": offer.vehicleDesc!,
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
	
	func setOngoing(offer: Offer?) {
		guard let offer = offer else {
			print("Offer is invalid")
			
			return
		}

		let postOngoingOfferWithIdURL = self.postOffersURL + "\(offer.offerId!)/ongoing"
		
		let url = URL.init(string: postOngoingOfferWithIdURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func setCompleted(offer: Offer?) {
		guard let offer = offer else {
			print("Offer is invalid")
			
			return
		}
		
		let postCompletedOfferWithIdURL = self.postOffersURL + "\(offer.offerId!)/completed"
		
		let url = URL.init(string: postCompletedOfferWithIdURL)
		self.request = URLRequest.init(url: url!)
		self.request?.httpMethod = "POST"
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func getNearbyOffersWith(userLocation: CLLocation?) {
		if let userLocation = userLocation {
			let json: [String: Any] = ["lat": userLocation.coordinate.latitude, "lng": userLocation.coordinate.longitude]
			let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
			
			let url = URL.init(string: self.nearbyOffersURL)
			self.request = URLRequest.init(url: url!)
			self.request?.httpMethod = "POST"
			self.request?.httpBody = jsonData!
			
			self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
			self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
			self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
		}
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
	
	// MARK: Bookings
	func getAllBookingsForUser() {
		let url = URL.init(string: self.allBookingsForUserURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func getAllBookingsForOfferByOffer(id: Int?) {
		let getAllBookingsForOfferWithOfferIdURL = self.getAllBookingsForOffer + "/\(id!)/bookings"
		
		let url = URL.init(string: getAllBookingsForOfferWithOfferIdURL)
		self.request = URLRequest.init(url: url!)
		
		self.request?.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
		self.request?.addValue("application/json", forHTTPHeaderField: "Accept")
		self.request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
	}
	
	func book(offer: Offer, withPax pax: Int) {
		// not using pax for now
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
