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
	var authURL = "http://139.59.224.66/api/v1/auth"
	var allOffersURL = "http://139.59.224.66/api/v1/offers"
	var request: URLRequest?
	
	init() {
		print("This initializer is only for SignInViewController")
	}
	
	init(token: String?) {
		guard let token = token else {
			print("Token is not available")
			
			return
		}
		
		self.token = token
	}
	
	func setUserAuth(token: String?) {
		guard let token = token else {
			print("token needed")
			
			return
		}
		
		let string = "token=\(token)"
		var data = string.data(using: .utf8)
		
		let string2 = "&service=facebook"
		let data2 = string2.data(using: .utf8)
		data?.append(data2!)
		
		let postData = NSMutableData(data: "token=\(token)".data(using: String.Encoding.utf8)!)
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
				let vacancy = object["vacancy"] as? Int
				
				let offer = Offer.init(withEndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: meetupTime, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, vacancy: vacancy)

				
				offerArr.append(offer)
			}
		}
		
		return offerArr
	}

	
	func post(offer: Offer?, withToken token: String?) {
		if let offer = offer {
			let json: [String: Any] = ["end_addr": offer.endAddr!,
										"end_lat": offer.endLat!,
										"end_lng": offer.endLng!,
										"end_name": offer.endName!,
										"meetup_time": offer.meetupTime!,
										"start_addr": offer.startAddr!,
										"start_lat": offer.startLat!,
										"start_lng": offer.startLng!,
										"start_name": offer.startName!,
										"vacancy": offer.vacancy!,
										"vehicle_model": "Honda",
										"vehicle_number": "SJA456"]
			let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
			let url = URL.init(string: "http://139.59.224.66/api/v1/offers")
			
			var request = URLRequest.init(url: url!)
			request.httpMethod = "POST"
			request.httpBody = jsonData
			
			request.addValue("application/json", forHTTPHeaderField: "Accept")
			request.addValue("application/json", forHTTPHeaderField: "Content-Type")
			request.addValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
			
			let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
				if let response = response {
					print("Response: \(response)")
				}
				
				if let data = data {
					if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) {
						print("json: \(json)")
					}
				}
			}
			task.resume()
		}
	}
	
	func setAllOffers() {
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
	
//	func getAllOffersFor(tableView: UITableView?) {
//		let url = URL.init(string: "http://139.59.224.66/api/v1/offers")
//		var request = URLRequest.init(url: url!)
//		request.addValue("application/json", forHTTPHeaderField: "Accept")
//		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//		request.addValue("Bearer \((UIApplication.shared.delegate as! AppDelegate).jwt)", forHTTPHeaderField: "Authorization")
//		
//		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
//				print("getting offers")
//				
//				self.offerArr = database.convertJSONToOffer(json: json!)
//				
//				DispatchQueue.main.async {
//					self.tableView.reloadData()
//				}
//			}
//		}
//		
//		task.resume()
//	}
	
	func deleteOfferBy(id: Int?) {
		let url = URL.init(string: "http://139.59.224.66/api/v1/offers/\(id!)")
		var request = URLRequest.init(url: url!)
		
		request.httpMethod = "DELETE"
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
				print(json)
			}
		}
		
		task.resume()
	}
}
