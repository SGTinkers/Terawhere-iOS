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
	
	var database = (UIApplication.shared.delegate as! AppDelegate).database
	
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
		
		print("Date: \(dateString)")
		
		
		
		
		let endAddr = "\((endLocation?.placemark.subThoroughfare)!) \((endLocation?.placemark.thoroughfare)!)"
		let endName = (endLocation?.name)!
		let endLat = (self.endLocation?.placemark.coordinate.latitude)!
		let endLng = (self.endLocation?.placemark.coordinate.longitude)!
		
		let startAddr = "\((startLocation?.placemark.subThoroughfare)!) \((startLocation?.placemark.thoroughfare)!)"
		let startName = (startLocation?.name)!
		let startLat = (self.startLocation?.placemark.coordinate.latitude)!
		let startLng = (self.startLocation?.placemark.coordinate.longitude)!
		
		let offer = Offer.init(forPostWithEndAddr: endAddr, endLat: endLat, endLng: endLng, endName: endName, meetupTime: dateString, startAddr: startAddr, startLat: startLat, startLng: startLng, startName: startName, remarks: "Hello", userId: database.userId, vehicleDesc: "Red", vehicleModel: "Honda", vehicleNumber: 123, status: 1, vacancy: Int(self.vacancyTextfield.text!))
	
		self.database.post(offer: offer)
		
		let task = URLSession.shared.dataTask(with: (self.database.request)!) { (data, response, error) in
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

	override func viewWillAppear(_ animated: Bool) {
		if let endLocation = self.endLocation {
			self.endLocationLabel.text = "\(endLocation.name!), \(endLocation.placemark.subThoroughfare!) \(endLocation.placemark.thoroughfare!)"
		}
		
		if let startLocation = self.startLocation {
			self.startLocationLabel.text = "\(startLocation.name!), \(startLocation.placemark.subThoroughfare!) \(startLocation.placemark.thoroughfare!)"
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
