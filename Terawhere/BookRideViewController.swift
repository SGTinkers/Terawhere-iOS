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
	
	var tableItems = ["Meet pt name", "Meet pt", "Driver name", "Vacancy", "Vehicle model", "Vehicle number", "Pickup time", "Destination"]
	
	var meetupPointNameIndexPath = IndexPath.init(row: 0, section: 0)
	var meetupPointIndexPath = IndexPath.init(row: 1, section: 0)
	var driverNameIndexPath = IndexPath.init(row: 2, section: 0)
	var vacancyIndexPath = IndexPath.init(row: 3, section: 0)
	var carModelIndexPath = IndexPath.init(row: 4, section: 0)
	var vehicleNumberIndexPath = IndexPath.init(row: 5, section: 0)
	var pickupTimeIndexPath = IndexPath.init(row: 6, section: 0)
	var destinationIndexPath = IndexPath.init(row: 7, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		
		print("Offer id \((self.offer?.offerId)!)")
    }

	@IBAction func bookRide() {
		print("Book Ride: Offer id \((self.offer?.offerId)!)")
	
	
		let alertController = UIAlertController.init(title: "How many seats do you want to book?", message: "Defaults to 1 if no input", preferredStyle: .alert)
		alertController.addTextField { (textfield) in
			textfield.keyboardType = .numberPad
		}
		let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
		let bookAction = UIAlertAction.init(title: "Book", style: .default) { (action) in
			var pax = 1
		
			// if textfield is not empty
			if (alertController.textFields?[0].text?.isEmpty)! == false  {
				pax = Int((alertController.textFields?[0].text)!)!
			}
			
			self.database?.book(offer: self.offer!, withPax: pax)
			
			let task = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
				if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
					print("booking done: \(json!)")
					
					var messageTitle = "Yay"
					var message = "Book successful"
					
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
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		cell.textLabel?.text = self.tableItems[indexPath.row]
		cell.textLabel?.textAlignment = .left
		
		if indexPath == self.meetupPointNameIndexPath {
			cell.detailTextLabel?.text = String((offer?.startName)!)
		}
		
		if indexPath == self.meetupPointIndexPath {
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
		
		if indexPath == self.carModelIndexPath {
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
		
		return cell
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
