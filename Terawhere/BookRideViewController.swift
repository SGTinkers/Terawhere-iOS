//
//  BookRideViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 6/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class BookRideViewController: UIViewController, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!

	var database: Database?
	var offer: Offer?
	
	var tableItems = ["Driver name", "Meetup time", "Meetup place", "Destination", "Vacancy"]
	
	var driverNameIndexPath = IndexPath.init(row: 0, section: 0)
	var meetupTimeIndexPath = IndexPath.init(row: 1, section: 0)
	var meetupPlaceIndexPath = IndexPath.init(row: 2, section: 0)
	var destinationIndexPath = IndexPath.init(row: 3, section: 0)
	var vacancyIndexPath = IndexPath.init(row: 4, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		
		print("Offer id \((self.offer?.offerId)!)")
    }

	@IBAction func bookRide() {
		print("Book Ride: Offer id \((self.offer?.offerId)!)")
	
	
		let alertController = UIAlertController.init(title: "Are you sure?", message: "", preferredStyle: .alert)
//		alertController.addTextField { (textfield) in
//			textfield.keyboardType = .numberPad
//		}
		let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
		let bookAction = UIAlertAction.init(title: "Book", style: .default) { (action) in
			let pax = 1
		
			// if textfield is not empty
//			if (alertController.textFields?[0].text?.isEmpty)! == false  {
//				pax = Int((alertController.textFields?[0].text)!)!
//			}
			
			self.database?.book(offer: self.offer!, withPax: pax)
			
			let task = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
				if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
					print("booking done: \(json!)")
					
					var messageTitle = "Offer successfully booked"
					var message = ""
					
					// if anything goes wrong
					if let jsonError = json?["error"] as? String {
						print("Json error: \(jsonError)")
						
						if let jsonMessage = json?["message"] as? String {
							print("Json message: \(jsonMessage)")
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
			
			task.resume()
		}
		
		alertController.addAction(cancelAction)
		alertController.addAction(bookAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func dismissViewController() {
		self.dismiss(animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	// MARK: Table view data source
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.tableItems.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ViewOfferTableViewCell
		
		cell?.customTextLabel?.text = self.tableItems[indexPath.row]
		cell?.isUserInteractionEnabled = false
		
		if indexPath == self.meetupPlaceIndexPath {
			cell?.customDetailTextLabel?.text = String((offer?.startAddr)!)
		}
		
		if indexPath == self.driverNameIndexPath {
			// get single offer
			self.database?.get(offer: offer)
			let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
				let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any]
				
				let actualJson = json??["data"] as? [String: Any]
				
				let driverName = actualJson?["name"] as? String
				
				DispatchQueue.main.async {
					cell?.customDetailTextLabel?.text = driverName
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
				
					cell?.customDetailTextLabel?.text = String(vacancy)
				}
			})
			
			dataTask.resume()
		}
		
		if indexPath == self.meetupTimeIndexPath {
			let dateHelper = DateHelper()
			let localTime = dateHelper.localTimeFrom(dateString: (offer?.meetupTime)!)
//			let localTime = dateHelper.localTimeFrom(dateString: (offer?.meetupTime)!, withCustomFormat: "yyyy-MM-dd hh:mm:ss a")
			
			cell?.customDetailTextLabel?.text = localTime
		}
		
		if indexPath == self.destinationIndexPath {
			cell?.customDetailTextLabel?.text = String((offer?.endName)!)
		}
		
		return cell!
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}
