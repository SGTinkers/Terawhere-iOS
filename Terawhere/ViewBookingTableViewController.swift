//
//  ViewBookingTableViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 14/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class ViewBookingTableViewController: UITableViewController {

	var database: Database?
	var booking: Booking?
	var offer: Offer?

	var tableItems = ["Meet place", "Driver name", "Vacancy", "Vehicle model", "Vehicle number", "Pickup time", "Destination"]
	
	var meetupPlaceIndexPath = IndexPath.init(row: 0, section: 0)
	var driverNameIndexPath = IndexPath.init(row: 1, section: 0)
	var vacancyIndexPath = IndexPath.init(row: 2, section: 0)
	var vehicleModelIndexPath = IndexPath.init(row: 3, section: 0)
	var vehicleNumberIndexPath = IndexPath.init(row: 4, section: 0)
	var pickupTimeIndexPath = IndexPath.init(row: 5, section: 0)
	var destinationIndexPath = IndexPath.init(row: 6, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func cancelBooking() {
		print("Booking View: Book id \((self.booking?.id)!)")
		print("Booking View: Offer id \((self.offer?.offerId)!)")
		
		self.database?.cancel(booking: self.booking)
		
		let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
				print(json)
				
				DispatchQueue.main.async {
					let alert = UIAlertController.init(title: "Booking successfully cancelled", message: "", preferredStyle: .alert)
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

	@IBAction func displayOptions() {
		let alert = UIAlertController.init(title: "Do you want to cancel your booking?", message: "", preferredStyle: .actionSheet)
		let cancelBooking = UIAlertAction.init(title: "Cancel booking", style: .destructive) { (action) in
			self.cancelBooking()
		}
		let dismiss = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
		
		alert.addAction(cancelBooking)
		alert.addAction(dismiss)
		
		self.present(alert, animated: true, completion: nil)
	}

	
	// MARK: Table view data source
	override public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tableItems.count
	}
	
	override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = self.tableItems[indexPath.row]
		cell.textLabel?.textAlignment = .left
		
		cell.isUserInteractionEnabled = false
		
		if indexPath == self.meetupPlaceIndexPath {
			cell.detailTextLabel?.text = String((offer?.startAddr)!)
		}
		
		if indexPath == self.driverNameIndexPath {
			cell.detailTextLabel?.text = String((offer?.name)!)
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
			cell.detailTextLabel?.text = String((offer?.vehicleNumber)!)?.uppercased()
		}
		
		if indexPath == self.pickupTimeIndexPath {
			let dateHelper = DateHelper()
			let localTime = dateHelper.localTimeFrom(dateString: (offer?.meetupTime)!)
		
			cell.detailTextLabel?.text = localTime
		}
		
		if indexPath == self.destinationIndexPath {
			cell.detailTextLabel?.text = String((offer?.endName)!)
		}
		
		return cell
	}
}
