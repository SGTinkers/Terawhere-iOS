//
//  ViewOfferViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 5/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class ViewOfferTableViewController: UITableViewController {

	var database: Database?
	var offer: Offer?
	
	var tableItems = ["Meet place", "Driver name", "Vacancy", "Vehicle model", "Vehicle number", "Pickup time", "Destination"]
	var passengers = [String]()
	
	var meetupPlaceIndexPath = IndexPath.init(row: 0, section: 0)
	var driverNameIndexPath = IndexPath.init(row: 1, section: 0)
	var vacancyIndexPath = IndexPath.init(row: 2, section: 0)
	var vehicleModelIndexPath = IndexPath.init(row: 3, section: 0)
	var vehicleNumberIndexPath = IndexPath.init(row: 4, section: 0)
	var pickupTimeIndexPath = IndexPath.init(row: 5, section: 0)
	var destinationIndexPath = IndexPath.init(row: 6, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.database?.getAllBookingsForOfferByOffer(id: (self.offer?.offerId)!)
		let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
			if let actualJson = json??["data"] as? [[String: Any]] {
				if actualJson.count > 0 {
					print("Hello json: \(actualJson)")
					
					for booking in actualJson {
						let pax = booking["pax"] as? Int
						
						let user = booking["user"] as? [String: Any]
						let name = user?["name"] as? String
						
						self.passengers.append("\(name!) booked \(pax!) seat(s)")
					}
					
					self.tableView.reloadData()
				}
			}
			
			print("Passenger count \(self.passengers.count)")
		}
		
		dataTask.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func displayOptions() {
		let alert = UIAlertController.init(title: "Do you want to delete your offer?", message: "", preferredStyle: .actionSheet)
		let delete = UIAlertAction.init(title: "Delete offer", style: .destructive) { (action) in
			self.deleteOffer()
		}
		let dismiss = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
		
		alert.addAction(delete)
		alert.addAction(dismiss)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func deleteOffer() {
		self.database?.delete(offer: self.offer)
		
		let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
				print(json)
				
				DispatchQueue.main.async {
					let alert = UIAlertController.init(title: "Offer successfully deleted", message: "", preferredStyle: .alert)
					let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: { (action) in
						self.navigationController?.popViewController(animated: true)
					})
					
					alert.addAction(okAction)
					
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
		
		dataTask.resume()
	}

	// MARK: Table view data source
	override public func numberOfSections(in tableView: UITableView) -> Int {
		if self.passengers.count > 0 {
			return 2
		}
		
		return 1
	}

	override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.passengers.count > 0 {
			var rows = 0
		
			if section == 0 {
				rows = self.tableItems.count
			}
			
			if section == 1 {
				rows = self.passengers.count
			}
			
			return rows
		}
		
		return self.tableItems.count
	}

	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		if indexPath.section == 0 {
			cell.textLabel?.text = self.tableItems[indexPath.row]
			
			if indexPath == self.meetupPlaceIndexPath {
				cell.detailTextLabel?.text = String((offer?.startAddr)!)
			}
			
			if indexPath == self.driverNameIndexPath {
				// get single offer
				self.database?.get(offer: offer)
				let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
					let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
					
					let actualJson = json??["data"] as? [String: Any]
					
					let driverName = actualJson?["name"] as? String
					
					DispatchQueue.main.async {
						cell.detailTextLabel?.text = driverName
					}
				}
				
				dataTask.resume()
			}
			
			if indexPath == self.vacancyIndexPath {
				var bookingsArr = [Booking]()
				
				self.database?.getAllBookingsForOfferByOffer(id: (self.offer?.offerId)!)
				let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!, completionHandler: { (data, response, error) in
					let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?]
					
					bookingsArr = (self.database?.convertJSONToBooking(json: json!!))!
					
					var paxBooked = 0
					
					for booking in bookingsArr {
						paxBooked = paxBooked + booking.paxBooked!
					}
					
					DispatchQueue.main.async {
						let vacancy = (self.offer?.vacancy)! - paxBooked
						
						cell.detailTextLabel?.text = String(vacancy)
					}
				})
				
				dataTask.resume()
			}
			
			if indexPath == self.vehicleModelIndexPath {
				cell.detailTextLabel?.text = (offer?.vehicleModel)!
			}
			
			if indexPath == self.vehicleNumberIndexPath {
				cell.detailTextLabel?.text = String((offer?.vehicleNumber)!)
			}
			
			if indexPath == self.pickupTimeIndexPath {
				let dateHelper = DateHelper()
				let localTime = dateHelper.localTimeFrom(dateString: (offer?.meetupTime)!)
				
				cell.detailTextLabel?.text = localTime
			}
			
			if indexPath == self.destinationIndexPath {
				cell.detailTextLabel?.text = String((offer?.endName)!)
			}
		}
		
		if self.passengers.count > 0 {
			if indexPath.section == 1 {
				cell.textLabel?.text = "Passenger"
				cell.detailTextLabel?.text = self.passengers[indexPath.row]
			}
		}

		cell.textLabel?.textAlignment = .left
		
		cell.isUserInteractionEnabled = false

		return cell
	}

    /*
     MARKvar Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destinationViewController.
         Pass the selected object to the new view controller.
    }
    */

}
