//
//  OffersViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 1/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class OffersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var noOffersView: UIView!

	var database = (UIApplication.shared.delegate as! AppDelegate).database
	var offersArr = [Offer]()
	var filteredOffersArr = [Offer]()
	
	let dateHelper = DateHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
    }

	override func viewWillAppear(_ animated: Bool) {
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		
		self.database.getAllOffersForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				print("Offer JSON: \(json)")
				
				// this array carries all user's offers
				self.offersArr = self.database.convertJSONToOffer(json: json!)
				
				// clear filtered array first
				self.filteredOffersArr.removeAll()
				
				for offer in self.offersArr {
					let utcDate = self.dateHelper.utcDate()
					let meetupTime = self.dateHelper.utcDateFrom(dateString: offer.meetupTime!)
					
					// today's offers
					if meetupTime! > utcDate! {
						print("Adding one offer for today")
						self.filteredOffersArr.append(offer)
					}
					
					// past offers
					if meetupTime! < utcDate! {
						print("Adding one offer for the past")
						self.database.setCompleted(offer: offer)
						
						let dataTask = URLSession.shared.dataTask(with: self.database.request!, completionHandler: { (data, response, error) in
							if let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
								print("json: \(json)")
							}
						})
						
						dataTask.resume()
					}
					
				}
				
				DispatchQueue.main.async {
					if self.filteredOffersArr.count > 0 {
						self.tableView.isHidden = false
						self.noOffersView.isHidden = true
					} else {
						self.tableView.isHidden = true
						self.noOffersView.isHidden = false
					}
					
					self.tableView.reloadData()
					
					self.activityIndicator.stopAnimating()
				}
			}
		}
		
		task.resume()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func showCreateOfferScreen() {
		let createOfferVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateOfferViewController") as? CreateOfferViewController
		createOfferVC?.database = self.database
	
		let navController = UINavigationController.init(rootViewController: createOfferVC!)
	
		self.present(navController, animated: true, completion: nil)
	}
	
	// MARK: Table view data source
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.filteredOffersArr.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? OffersTableViewCell
		
		// Configure the cell...
		let offer = self.filteredOffersArr[indexPath.row]
		
		cell?.destinationLabel.text = offer.endAddr!
		print("Start addr: \(offer.endAddr!)")
		
		let localMeetupTime = self.dateHelper.localTimeFrom(dateString: offer.meetupTime!)
		cell?.meetupLabel.text = "\(localMeetupTime) @ \(offer.startAddr!)"
		
		// getting vacancy
		var bookingsArr = [Booking]()
		
		self.database.getAllBookingsForOfferByOffer(id: offer.offerId!)
		let dataTask = URLSession.shared.dataTask(with: (self.database.request)!, completionHandler: { (data, response, error) in
			let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?]
			bookingsArr = (self.database.convertJSONToBooking(json: json!!))
			
			var paxBooked = 0
			
			for booking in bookingsArr {
				paxBooked = paxBooked + booking.paxBooked!
			}
			
			DispatchQueue.main.async {
				let vacancy = offer.vacancy! - paxBooked
				
				cell?.vacancyLabel.text = String(vacancy)
			}
		})
		
		dataTask.resume()
		
		cell?.mapView.isScrollEnabled = false
		
		cell?.mapView.removeAnnotations((cell?.mapView.annotations)!)
		cell?.mapView.selectedAnnotations.removeAll()
		
		let location = CLLocationCoordinate2D.init(latitude: offer.startLat!, longitude: offer.startLng!)
		
		let annotation = Location.init(withCoordinate: location, AndOffer: offer)
		cell?.mapView?.addAnnotation(annotation)
		
		let region = MKCoordinateRegionMakeWithDistance(location, 5000, 5000)
		cell?.mapView?.setRegion(region, animated: true)

		return cell!
	}

	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// MARK: tableview delegate
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let viewOfferTVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewOfferTableViewController") as? ViewOfferTableViewController else {
			print("View offer TVC errors out")
			
			return
		}
		
		// may need to retrieve in this view controller for driver name
		let offer = self.filteredOffersArr[indexPath.row]
		viewOfferTVC.offer = offer
		viewOfferTVC.database = self.database
		
		self.navigationController?.pushViewController(viewOfferTVC, animated: true)
	}

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "CreateOffer" {
			guard let createOfferVC = segue.destination as? CreateOfferViewController else {
				print("Create offer view controller errors out")
				
				return
			}

			createOfferVC.database = self.database
		}
    }

}
