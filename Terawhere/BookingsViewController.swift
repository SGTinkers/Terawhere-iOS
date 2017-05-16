//
//  BookingViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 10/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class BookingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var segmentedControl: UISegmentedControl!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var noBookingsView: UIView!
	
	var database = (UIApplication.shared.delegate as! AppDelegate).database
	var bookingsArr = [Booking]()
	var filteredBookingsArr = [Booking]()

	let date = Date()
	let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.separatorStyle = .none
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.activityIndicator.activityIndicatorViewStyle = .gray
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		
		self.database.getAllBookingsForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				print("booking json: \(json)")
				
				// this array carries all user's offers
				self.bookingsArr = self.database.convertJSONToBooking(json: json!)
				
				// clear filtered array first
				self.filteredBookingsArr.removeAll()
				
				print("booking arr count: \(self.bookingsArr.count)")
				
				for booking in 0 ..< self.bookingsArr.count {
					self.database.getOfferBy(id: self.bookingsArr[booking].offerId!)
					
					let innerTask = URLSession.shared.dataTask(with: self.database.request!, completionHandler: { (data, response, error) in
						let innerJson = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?]
						let offer = self.database.convertJSONToOfferObject(json: innerJson!!)
						
						
						self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
						self.dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
						let tmpDateString = self.dateFormatter.string(from: self.date)
						
						let utcDate = self.dateFormatter.date(from: tmpDateString)
						let meetupDate = self.dateFormatter.date(from: (offer?.meetupTime)!)
						
						
						
						if self.segmentedControl.selectedSegmentIndex == 0 {
							// booking nil means booking has not been cancelled
							// do not append cancelled bookings generally
							if self.bookingsArr[booking].deletedDate == nil {
								if meetupDate! > utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[booking])
								}
							}
							
						} else if self.segmentedControl.selectedSegmentIndex == 1 {
							if self.bookingsArr[booking].deletedDate == nil {
								print("Booking is def nil")
								
								if meetupDate! < utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[booking])
								}
							}
						}
						
						// an async call in an async call
						// only execute in the main queue after the last item in the for loop
						// otherwise, it ends up being an async bug
						// and those are really tough to handle
						if booking < self.bookingsArr.count {
							DispatchQueue.main.async {
								if self.filteredBookingsArr.count > 0 {
									self.tableView.isHidden = false
									self.noBookingsView.isHidden = true
								} else {
									self.tableView.isHidden = true
									self.noBookingsView.isHidden = false
								}
								
								self.tableView.reloadData()
								
								self.activityIndicator.stopAnimating()
							}
						}
					})
					
					innerTask.resume()
				}
			}
		}
		
		task.resume()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func changeSegmentedControl() {
		self.activityIndicator.activityIndicatorViewStyle = .gray
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		
		self.database.getAllBookingsForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				print("booking json: \(json)")
				
				// this array carries all user's offers
				self.bookingsArr = self.database.convertJSONToBooking(json: json!)
				
				// clear filtered array first
				self.filteredBookingsArr.removeAll()
				
				print("booking arr count: \(self.bookingsArr.count)")
				
				for booking in 0 ..< self.bookingsArr.count {
					self.database.getOfferBy(id: self.bookingsArr[booking].offerId!)
					
					let innerTask = URLSession.shared.dataTask(with: self.database.request!, completionHandler: { (data, response, error) in
						let innerJson = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?]
						let offer = self.database.convertJSONToOfferObject(json: innerJson!!)
					
						
						self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
						self.dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
						let tmpDateString = self.dateFormatter.string(from: self.date)
						
						let utcDate = self.dateFormatter.date(from: tmpDateString)
						let meetupDate = self.dateFormatter.date(from: (offer?.meetupTime)!)

					
						
						if self.segmentedControl.selectedSegmentIndex == 0 {
							// booking nil means booking has not been cancelled
							// do not append cancelled bookings generally
							if self.bookingsArr[booking].deletedDate == nil {
								if meetupDate! > utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[booking])
								}
							}
							
						} else if self.segmentedControl.selectedSegmentIndex == 1 {
							if self.bookingsArr[booking].deletedDate == nil {
								print("Booking is def nil")

								if meetupDate! < utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[booking])
								}
							}
						}
						
						// an async call in an async call
						// only execute in the main queue after the last item in the for loop
						// otherwise, it ends up being an async bug
						// and those are really tough to handle
						if booking < self.bookingsArr.count {
							DispatchQueue.main.async {
								if self.filteredBookingsArr.count > 0 {
									self.tableView.isHidden = false
									self.noBookingsView.isHidden = true
								} else {
									self.tableView.isHidden = true
									self.noBookingsView.isHidden = false
								}
								
								self.tableView.reloadData()
								
								self.activityIndicator.stopAnimating()
							}
						}
					})
					
					innerTask.resume()
				}
			}
		}
		
		task.resume()
	}

	// MARK: Table view data source
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.filteredBookingsArr.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookingsTableViewCell
		
		// Configure the cell...
		cell?.booking = self.filteredBookingsArr[indexPath.row]
		
		// get offer
		self.database.getOfferBy(id: (cell?.booking?.offerId)!)
		let dataTask = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				// always check if offer is valid
				// some offers are nil
				guard let offer = self.database.convertJSONToOfferObject(json: json!) else {
					print("Offer is nil")
					
					return
				}
				
				DispatchQueue.main.async {
					cell?.carModelLabel.text = offer.vehicleModel!
					cell?.carNumberLabel.text = offer.vehicleNumber!
					
					
					self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
					self.dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
					let date = self.dateFormatter.date(from: offer.meetupTime!)
					
					self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
					self.dateFormatter.dateFormat = "hh:mm a"
					let localMeetupTime = self.dateFormatter.string(from: date!)
					cell?.pickupTimeLabel.text = localMeetupTime
					
					cell?.pickupLocationLabel.text = offer.startAddr!
					
					cell?.mapView.isScrollEnabled = false
					
					cell?.mapView.removeAnnotations((cell?.mapView.annotations)!)
					cell?.mapView.selectedAnnotations.removeAll()
					
					let location = CLLocationCoordinate2D.init(latitude: offer.startLat!, longitude: offer.startLng!)
					
					let annotation = Location.init(withCoordinate: location, AndOffer: offer)
					cell?.mapView?.addAnnotation(annotation)
					
					let region = MKCoordinateRegionMakeWithDistance(location, 5000, 5000)
					cell?.mapView?.setRegion(region, animated: true)
				}
			}
		}
		
		dataTask.resume()
		
		return cell!
	}
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// MARK: tableview delegate
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// only display details if it is current bookings
		if self.segmentedControl.selectedSegmentIndex == 0 {
			guard let viewBookingVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewBookingTableViewController") as? ViewBookingTableViewController else {
				print("View booking VC errors out")
				
				return
			}
			
			let cell = self.tableView.cellForRow(at: indexPath) as? BookingsTableViewCell
			let booking = self.bookingsArr[indexPath.row]
			print("Did select: Booking id: \(booking.id!)")
			
			viewBookingVC.booking = booking
			viewBookingVC.offer = cell?.offer
			viewBookingVC.database = self.database
			
			self.navigationController?.pushViewController(viewBookingVC, animated: true)
		}
	}

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//		if segue.identifier == "ViewBooking" {
//			print("Hello there booking")
//		
//			let selectedIndexPath = self.tableView.indexPathForSelectedRow
//		
//			let booking = self.bookingsArr[(selectedIndexPath?.row)!]
//		
//			let viewBookingVC = segue.destination as? ViewBookingTableViewController
//			viewBookingVC?.booking = booking
//			viewBookingVC?.database = self.database
//		}
//    }

}
