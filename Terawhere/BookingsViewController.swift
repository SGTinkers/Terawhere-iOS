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
	var offersArr = [Offer]()
	var filteredBookingsArr = [Booking]()
	
	let dateHelper = DateHelper()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.separatorStyle = .none
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		
		self.database.getAllBookingsForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				// clear arrays first
				self.filteredBookingsArr.removeAll()
				self.offersArr.removeAll()
				
				self.bookingsArr = self.database.convertJSONToBooking(json: json!)
				
				if let actualJsonData = json?["data"] as? [[String: Any]] {
					for object in actualJsonData {
						let offer = Offer()
						
						let offerObject = object["offer"] as? [String: Any]
						
						let deletedDate = offerObject?["deleted_at"] as? String
						let endAddr = offerObject?["end_addr"] as? String
						let id = offerObject?["id"] as? Int
						let meetupTime = offerObject?["meetup_time"] as? String
						let startAddr = offerObject?["start_addr"] as? String
						let vehicleModel = offerObject?["vehicle_model"] as? String
						let vehicleNumber = offerObject?["vehicle_number"] as? String
						
						offer.deletedDateString = deletedDate
						offer.endAddr = endAddr
						offer.offerId = id
						offer.meetupTime = meetupTime
						offer.startAddr = startAddr
						offer.vehicleModel = vehicleModel
						offer.vehicleNumber = vehicleNumber
						
						self.offersArr.append(offer)
					}
				}
				
				
				if self.bookingsArr.count > 0 {
					for count in 0 ..< self.bookingsArr.count {
						print("Booking View: Book id \(self.bookingsArr[count].id!)")
						print("Booking View: Offer id \(self.bookingsArr[count].offerId!)")
						
						let localTime = self.dateHelper.localTimeFrom(dateString: self.offersArr[count].meetupTime!, withCustomFormat: "yyyy-MM-dd hh:mm:ss a")
						print("Offer local time \(localTime)")
						
						let utcDate = self.dateHelper.utcDate()
						let meetupDate = self.dateHelper.utcDateFrom(dateString: self.offersArr[count].meetupTime!)
						
						if self.segmentedControl.selectedSegmentIndex == 0 {
							// if booking has not been cancelled
							if self.bookingsArr[count].deletedDate == nil {
								// if the booking is in the future
								if meetupDate! > utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[count])
								}
							}
						} else if self.segmentedControl.selectedSegmentIndex == 1 {
							// if booking has not been cancelled
							if self.bookingsArr[count].deletedDate == nil {
								// if the booking is in the future
								if meetupDate! < utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[count])
								}
							}
						}
						
						// wait for last item before reloading
						if count < self.bookingsArr.count {
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
					}
				} else {
					DispatchQueue.main.async {
						self.tableView.isHidden = true
						self.noBookingsView.isHidden = false
						
						self.activityIndicator.stopAnimating()
					}
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
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		
		self.database.getAllBookingsForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				// clear arrays first
				self.filteredBookingsArr.removeAll()
				self.offersArr.removeAll()
				
				self.bookingsArr = self.database.convertJSONToBooking(json: json!)
				
				if let actualJsonData = json?["data"] as? [[String: Any]] {
					for object in actualJsonData {
						let offer = Offer()
						
						let offerObject = object["offer"] as? [String: Any]
						
						let deletedDate = offerObject?["deleted_at"] as? String
						let endAddr = offerObject?["end_addr"] as? String
						let id = offerObject?["id"] as? Int
						let meetupTime = offerObject?["meetup_time"] as? String
						let startAddr = offerObject?["start_addr"] as? String
						let vehicleModel = offerObject?["vehicle_model"] as? String
						let vehicleNumber = offerObject?["vehicle_number"] as? String
						
						offer.deletedDateString = deletedDate
						offer.endAddr = endAddr
						offer.offerId = id
						offer.meetupTime = meetupTime
						offer.startAddr = startAddr
						offer.vehicleModel = vehicleModel
						offer.vehicleNumber = vehicleNumber
						
						self.offersArr.append(offer)
					}
				}
				
				
				if self.bookingsArr.count > 0 {
					for count in 0 ..< self.bookingsArr.count {
						print("Booking View: Book id \(self.bookingsArr[count].id!)")
						print("Booking View: Offer id \(self.bookingsArr[count].offerId!)")
						
						let localTime = self.dateHelper.localTimeFrom(dateString: self.offersArr[count].meetupTime!, withCustomFormat: "yyyy-MM-dd hh:mm:ss a")
						print("Offer local time \(localTime)")
						
						let utcDate = self.dateHelper.utcDate()
						let meetupDate = self.dateHelper.utcDateFrom(dateString: self.offersArr[count].meetupTime!)
						
						if self.segmentedControl.selectedSegmentIndex == 0 {
							// if booking has not been cancelled
							if self.bookingsArr[count].deletedDate == nil {
								// if the booking is in the future
								if meetupDate! > utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[count])
								}
							}
						} else if self.segmentedControl.selectedSegmentIndex == 1 {
							// if booking has not been cancelled
							if self.bookingsArr[count].deletedDate == nil {
								// if the booking is in the future
								if meetupDate! < utcDate! {
									self.filteredBookingsArr.append(self.bookingsArr[count])
								}
							}
						}
						
						// wait for last item before reloading
						if count < self.bookingsArr.count {
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
					}
				} else {
					DispatchQueue.main.async {
						self.tableView.isHidden = true
						self.noBookingsView.isHidden = false
						
						self.activityIndicator.stopAnimating()
					}
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
		
		let offer = self.offersArr[indexPath.row]

		// get offer
		// API calls are needed here because of missing information
		self.database.getOfferBy(id: offer.offerId!)
		let dataTask = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				// always check if offer is valid
				// some offers are nil
				guard let offer = self.database.convertJSONToOfferObject(json: json!) else {
					print("Offer is nil")
					
					return
				}
				
				cell?.offer = offer
				
				DispatchQueue.main.async {
					cell?.carModelLabel.text = offer.vehicleModel!
					cell?.carNumberLabel.text = offer.vehicleNumber!

					let localMeetupTime = self.dateHelper.localTimeFrom(dateString: offer.meetupTime!)
					
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
			
			print("Did Select: Book id \((cell?.booking?.id)!)")
			print("Did Select: Offer id \((cell?.offer?.offerId)!)")
			
			viewBookingVC.booking = cell?.booking
			viewBookingVC.offer = cell?.offer
			viewBookingVC.database = self.database
			
			self.navigationController?.pushViewController(viewBookingVC, animated: true)
		}
	}
}
