//
//  CreateOfferViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 1/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class CreateOfferViewController: UIViewController, UITextFieldDelegate, LocationSelectProtocol {
	
	@IBOutlet var scrollView: UIScrollView!

	@IBOutlet var endLocationLabel: UILabel!
	@IBOutlet var startLocationLabel: UILabel!
	
	@IBOutlet var vacancyTextfield: UITextField! // might want to change this interface
	
	var database: Database?
	
	var endLocation: MKMapItem?, startLocation: MKMapItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		let createButton  = UIBarButtonItem.init(title: "Create", style: .plain, target: self, action: #selector(createOffer))
		self.navigationItem.rightBarButtonItem = createButton
    }
	
	func createOffer() {
		let date = Date()
		let dateFormatter = DateFormatter()

		dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
		
		var dateString = dateFormatter.string(from: date)
		
		// get the date object
		if let date = dateFormatter.date(from: dateString) {
			// setup a current time zone formatted dateFormatter
			dateFormatter.timeZone = TimeZone.autoupdatingCurrent
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
			
			// get the string
			dateString = dateFormatter.string(from: date)
		}
		
		guard let endLocation = self.endLocation else {
			print("End location unavailable")
			
			return
		}
		
		guard let endSubThoroughfare = endLocation.placemark.subThoroughfare else {
			print("end subThoroughfare is unavailable")
			
			return
		}
		
		guard let endThoroughfare = endLocation.placemark.thoroughfare else {
			print("end thoroughfare is unavailable")
			
			return
		}
		
		guard let startLocation = self.startLocation else {
			print("Start location unavailable")
			
			return
		}
		
		guard let startSubThoroughfare = startLocation.placemark.subThoroughfare else {
			print("start subThoroughfare is unavailable")
			
			return
		}
		
		guard let startThoroughfare = startLocation.placemark.thoroughfare else {
			print("start thoroughfare is unavailable")
			
			return
		}
		
		let endAddr = "\(endLocation.name!), \(endSubThoroughfare) \(endThoroughfare)"
		let endName = endLocation.name!
		let endLat = (self.endLocation?.placemark.coordinate.latitude)!
		let endLng = (self.endLocation?.placemark.coordinate.longitude)!
		
		let startAddr = "\(startLocation.name!), \(startSubThoroughfare) \(startThoroughfare)"
		let startName = startLocation.name!
		let startLat = (self.startLocation?.placemark.coordinate.latitude)!
		let startLng = (self.startLocation?.placemark.coordinate.longitude)!
		
		let offer = Offer.init(forPostWithEndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: dateString, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, remarks: "Hello", userId: (self.database?.userId)!, vehicleDesc: "Red", vehicleModel: "Honda", vehicleNumber: "SJA756", status: 1, vacancy: Int(self.vacancyTextfield.text!))
	
		self.database?.post(offer: offer)
		
		let task = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			if let response = response {
				print("Response: \(response)")
			}
			
			if let data = data {
				if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) {
					print("json: \(json)")
					
					DispatchQueue.main.async {
						self.tabBarController?.navigationController?.popViewController(animated: true)
					}
				}
			}
		}
		task.resume()
	}

	override func viewWillAppear(_ animated: Bool) {
		if let endLocation = self.endLocation {
			guard let subThoroughfare = endLocation.placemark.subThoroughfare else {
				print("subThoroughfare is unavailable")
				
				return
			}
			
			guard let thoroughfare = endLocation.placemark.thoroughfare else {
				print("thoroughfare is unavailable")
				
				return
			}
		
			self.endLocationLabel.text = "\(endLocation.name!), \(subThoroughfare) \(thoroughfare)"
		}
		
		if let startLocation = self.startLocation {
			guard let subThoroughfare = startLocation.placemark.subThoroughfare else {
				print("subThoroughfare is unavailable")
				
				return
			}
			
			guard let thoroughfare = startLocation.placemark.thoroughfare else {
				print("thoroughfare is unavailable")
				
				return
			}
		
			self.startLocationLabel.text = "\(startLocation.name!), \(subThoroughfare) \(thoroughfare)"
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: Textfield delegate
//	public func textFieldDidBeginEditing(_ textField: UITextField) {
//		if self.remarksTextfield.isFirstResponder {
//			let point = CGPoint.init(x: 0, y: self.remarksTextfield.frame.origin.y - 50)
//			self.scrollView.setContentOffset(point, animated: true)
//		}
//	}
//	
//	public func textFieldDidEndEditing(_ textField: UITextField) {
//		self.scrollView.setContentOffset(.zero, animated: true)
//	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	
		return true
	}
	
	// MARK: Location Search delegate
	func use(mapItem: MKMapItem, forLocationState state: String) {
		if state == "end" {
			self.endLocation = mapItem
		
			self.endLocationLabel.text = mapItem.name
		}
		
		if state == "start" {
			self.startLocation = mapItem
		
			self.startLocationLabel.text = mapItem.name
		}
	}
	
	// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		let destinationVC = segue.destination as? LocationSearchTableViewController
		
		if segue.identifier == "LocationSearchEnd" {
			destinationVC?.state = "end"
		}
		
		if segue.identifier == "LocationSearchStart" {
			destinationVC?.state = "start"
		}
		
		destinationVC?.delegate = self
    }
}
