//
//  CreateOfferViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 1/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class CreateOfferViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SetTimeProtocol, LocationSelectProtocol {
	
	@IBOutlet var tableView: UITableView!
	
	var database: Database?
	
	var vehicleArr = ["Vehicle description", "Vehicle model", "Vehicle number", "Vacancy"]
	var timeAndLocation = ["Pickup time", "Meet pt name", "Meet pt", "Destination"]
	var remarks = ["Remarks"]
	
	// mostly for didSelect tableview method
	var vehicleDescIndexPath = IndexPath.init(row: 0, section: 0)
	var vehicleModelIndexPath = IndexPath.init(row: 1, section: 0)
	var vehicleNumberIndexPath = IndexPath.init(row: 2, section: 0)
	var vacancyIndexPath = IndexPath.init(row: 3, section: 0)
	
	var pickupTimeIndexPath = IndexPath.init(row: 0, section: 1)
	var meetupPointNameIndexPath = IndexPath.init(row: 1, section: 1)
	var meetupPointIndexPath = IndexPath.init(row: 2, section: 1)
	var destinationIndexPath = IndexPath.init(row: 3, section: 1)
	
	var remarksIndexPath = IndexPath.init(row: 0, section: 2)
	
	// date stuff
	var dateString = ""
	var date: Date?
	let dateHelper = DateHelper()
	
	var endLocation: MKMapItem?, startLocation: MKMapItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.tableView.dataSource = self
		self.tableView.delegate = self
		
		self.tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 0)
    }
	
	@IBAction func createOffer() {
		// addr vars
		var endSubThoroughfare = ""
		var endThoroughfare = ""
		var startSubThoroughfare = ""
		var startThoroughfare = ""
	
		// location vars
		guard let endLocation = self.endLocation else {
			print("End location unavailable")
			
			return
		}
		
		guard let startLocation = self.startLocation else {
			print("Start location unavailable")
			
			return
		}
		
		if let tmpEndSubThoroughfare = endLocation.placemark.subThoroughfare {
			endSubThoroughfare = tmpEndSubThoroughfare
		}
		
		if let tmpEndThoroughfare = endLocation.placemark.thoroughfare {
			endThoroughfare = tmpEndThoroughfare
		}
		
		if let tmpStartSubThoroughfare = startLocation.placemark.subThoroughfare {
			startSubThoroughfare = tmpStartSubThoroughfare
		}
		
		if let tmpStartThoroughfare = startLocation.placemark.thoroughfare {
			startThoroughfare = tmpStartThoroughfare
		}
		
		// vehicle vars
		let vehicleDescCell = self.tableView.cellForRow(at: self.vehicleDescIndexPath) as? CreateOfferTableViewCell
		let vehicleDesc = (vehicleDescCell?.textfield.text)!
		
		let vehicleModelCell = self.tableView.cellForRow(at: self.vehicleModelIndexPath) as? CreateOfferTableViewCell
		let vehicleModel = (vehicleModelCell?.textfield.text)!
		
		let vehicleNumberCell = self.tableView.cellForRow(at: self.vehicleNumberIndexPath) as? CreateOfferTableViewCell
		let vehicleNumber = (vehicleNumberCell?.textfield.text)!
		print("Vehicle Number: \(vehicleNumber)")
		let vehicleNumberTrimmed = vehicleNumber.replacingOccurrences(of: " ", with: "")
		print("Vehicle Number trimmed: \(vehicleNumberTrimmed)")
		
		let vacancyCell = self.tableView.cellForRow(at: self.vacancyIndexPath) as? CreateOfferTableViewCell
		let vacancy = (vacancyCell?.textfield.text)!
		
		
		// address setting
		let endAddr = "\(endLocation.name!), \(endSubThoroughfare) \(endThoroughfare)"
		let endName = endLocation.name!
		let endLat = (self.endLocation?.placemark.coordinate.latitude)!
		let endLng = (self.endLocation?.placemark.coordinate.longitude)!
		
		let startAddr = "\(startLocation.name!), \(startSubThoroughfare) \(startThoroughfare)"
		
		let meetupPointNameCell = self.tableView.cellForRow(at: self.meetupPointNameIndexPath) as? CreateOfferTableViewCell
		let startName = (meetupPointNameCell?.textfield.text)!
		let startLat = (self.startLocation?.placemark.coordinate.latitude)!
		let startLng = (self.startLocation?.placemark.coordinate.longitude)!
		
		let remarksCell = self.tableView.cellForRow(at: self.remarksIndexPath) as? CreateOfferTableViewCell
		let remarks = (remarksCell?.textfield.text)!
		
		self.dateString = self.dateHelper.utcDateStringFrom(date: self.date!)
		
		let offer = Offer.init(forPostWithEndAddr: endAddr,
							   endLat: endLat,
							   endLng: endLng,
							   endName: endName,
							   meetupTime: self.dateString,
							   startAddr: startAddr,
							   startLat: startLat,
							   startLng: startLng,
							   startName: startName,
							   remarks: remarks,
							   userId: (self.database?.userId)!,
							   vehicleDesc: vehicleDesc,
							   vehicleModel: vehicleModel,
							   vehicleNumber: vehicleNumberTrimmed,
							   status: 1,
							   vacancy: Int(vacancy))
	
		self.database?.post(offer: offer)
		
		let task = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			if let response = response {
				print("Response: \(response)")
			}
			
			if let data = data {
				if let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
					print("json: \(json)")
					
					var messageTitle = "Yay"
					var message = "Offer successfully created"
					
					// if anything goes wrong
					if let _ = json?["error"] as? String {
						if let jsonMessage = json?["message"] as? String {
							messageTitle = "Oops"
							message = jsonMessage
						}
					}
					
					DispatchQueue.main.async {
						let alert = UIAlertController.init(title: messageTitle, message: message, preferredStyle: .alert)
						let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
							self.dismiss(animated: true, completion: nil)
						})
						
						alert.addAction(okAction)
						
						self.present(alert, animated: true, completion: nil)
					}
				}
			}
		}
		task.resume()
	}

	override func viewWillAppear(_ animated: Bool) {
		// things that require to be appeared everytime the view loads
	
		let dateCell = self.tableView.cellForRow(at: self.pickupTimeIndexPath) as? CreateOfferTableViewCell
		dateCell?.textfield.text = self.dateString
		
		guard let startLocation = self.startLocation else {
			print("start location is unavailable")
			
			return
		}
		
		let meetupPointCell = self.tableView.cellForRow(at: self.meetupPointIndexPath) as? CreateOfferTableViewCell
		meetupPointCell?.textfield.text = startLocation.placemark.name!
		
		guard let endLocation = self.endLocation else {
			print("end location is unavailable")
			
			return
		}
		
		let destinationCell = self.tableView.cellForRow(at: self.destinationIndexPath) as? CreateOfferTableViewCell
		destinationCell?.textfield.text = endLocation.placemark.name!
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func dismissViewController() {
		self.dismiss(animated: true, completion: nil)
	}
	
	// MARK: tableview data source
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		var rows = 0
	
		if section == 0 {
			rows = self.vehicleArr.count
		}
		
		if section == 1 {
			rows = self.timeAndLocation.count
		}
		
		if section == 2 {
			rows = self.remarks.count
		}
		
		return rows
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CreateOfferTableViewCell
		
		// Configure the cell...
		if indexPath.section == 0 {
			cell?.textfield.placeholder = self.vehicleArr[indexPath.row]
			
			// make sure every other textfield can be dismissed by hitting the return key
			cell?.textfield.delegate = self
			
			if indexPath.row == 3 { // vacancy keyboard numeric only
				cell?.textfield.keyboardType = .numberPad
			}
		}
		
		if indexPath.section == 1 {
			cell?.textfield.placeholder = self.timeAndLocation[indexPath.row]
			
			if indexPath.row == 1 {
				// this is meeting point name where user can input custom name
				cell?.textfield.isEnabled = true
				cell?.textfield.delegate = self
			} else {
				cell?.textfield.isEnabled = false
			}
		}
		
		if indexPath.section == 2 {
			cell?.textfield.placeholder = self.remarks[indexPath.row]
			cell?.textfield.delegate = self
			
			// this is to identify remarks textfield
			// make sure only remarks textfield needs scrolling
			cell?.textfield.tag = 1
		}
		
		cell?.selectionStyle = .none
		
		return cell!
	}
	
	// MARK: tableview delegate
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath == self.vehicleDescIndexPath {
			let cell = self.tableView.cellForRow(at: indexPath) as? CreateOfferTableViewCell
			cell?.textfield.becomeFirstResponder()
		}
		
		if indexPath == self.vehicleModelIndexPath {
			let cell = self.tableView.cellForRow(at: indexPath) as? CreateOfferTableViewCell
			cell?.textfield.becomeFirstResponder()
		}
		
		if indexPath == self.vehicleNumberIndexPath {
			let cell = self.tableView.cellForRow(at: indexPath) as? CreateOfferTableViewCell
			cell?.textfield.becomeFirstResponder()
		}
		
		if indexPath == self.vacancyIndexPath {
			let cell = self.tableView.cellForRow(at: indexPath) as? CreateOfferTableViewCell
			cell?.textfield.becomeFirstResponder()
		}
		
		if indexPath == self.pickupTimeIndexPath {
			guard let pickupTimeVC = self.storyboard?.instantiateViewController(withIdentifier: "PickupTimeViewController") as? PickupTimeViewController else {
				print("Pick up time VC errors out")
				
				return
			}
			
			let navController = UINavigationController.init(rootViewController: pickupTimeVC)
			
			pickupTimeVC.delegate = self
			
			self.present(navController, animated: true)
		}
	
		if indexPath == self.meetupPointIndexPath {
			guard let locationSearchTVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as? LocationSearchTableViewController else {
				print("Location search TVC errors out")
				
				return
			}
			
			
			locationSearchTVC.state = "start"
			locationSearchTVC.delegate = self
			
			self.navigationController?.pushViewController(locationSearchTVC, animated: true)
		}
		
		if indexPath == self.destinationIndexPath {
			guard let locationSearchTVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as? LocationSearchTableViewController else {
				print("Location search TVC errors out")
				
				return
			}
			
			locationSearchTVC.state = "end"
			locationSearchTVC.delegate = self
			
			self.navigationController?.pushViewController(locationSearchTVC, animated: true)
		}
	
		if indexPath == self.remarksIndexPath {
			let cell = self.tableView.cellForRow(at: indexPath) as? CreateOfferTableViewCell
			cell?.textfield.becomeFirstResponder()
		}
	}
	
	// MARK: Textfield delegate
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField.tag == 1 {
			let point = CGPoint.init(x: 0, y: textField.frame.origin.y + 100)
			self.tableView.setContentOffset(point, animated: true)
		}
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		self.tableView.setContentOffset(.zero, animated: true)
	}
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	
		return true
	}
	
	
	// MARK: Set time protocol
	func setTime(date: Date?) {
		self.date = date
		
		self.dateString = self.dateHelper.localTimeFrom(convertedDate: self.date!)
		
		let cell = self.tableView.cellForRow(at: self.pickupTimeIndexPath) as? CreateOfferTableViewCell
		cell?.textfield.text = self.dateString
	}

	// MARK: Location Search delegate
	func use(mapItem: MKMapItem, forLocationState state: String) {
		if state == "end" {
			self.endLocation = mapItem
		
			let cell = self.tableView.cellForRow(at: self.destinationIndexPath) as? CreateOfferTableViewCell
			cell?.textfield.text = (self.endLocation?.placemark.name)!
		}
		
		if state == "start" {
			self.startLocation = mapItem
			
			let cell = self.tableView.cellForRow(at: self.meetupPointIndexPath) as? CreateOfferTableViewCell
			cell?.textfield.text = (self.startLocation?.placemark.name)!
		}
	}
//
//	// MARK: - Navigation
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		// Get the new view controller using segue.destinationViewController.
//		// Pass the selected object to the new view controller.
//		let destinationVC = segue.destination as? LocationSearchTableViewController
//		
//		if segue.identifier == "LocationSearchEnd" {
//			destinationVC?.state = "end"
//		}
//		
//		if segue.identifier == "LocationSearchStart" {
//			destinationVC?.state = "start"
//		}
//		
//		destinationVC?.delegate = self
//    }
}
