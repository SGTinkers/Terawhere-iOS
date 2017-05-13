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
	@IBOutlet var segmentedControl: UISegmentedControl!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!

	var database = (UIApplication.shared.delegate as! AppDelegate).database
	var offersArr = [Offer]()
	var filteredOffersArr = [Offer]()
	
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
	
		self.database.getAllOffersForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {

				// this array carries all user's offers
				self.offersArr = self.database.convertJSONToOffer(json: json!)
				
				self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
				self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

				// clear filtered array first
				self.filteredOffersArr.removeAll()
				
				for offer in self.offersArr {
					let updatedDate = self.dateFormatter.date(from: offer.updatedDateString!)
					
					let calendar = Calendar.init(identifier: .gregorian)
					let updatedDateComp = calendar.dateComponents([.year, .month, .day], from: updatedDate!)
					let updatedDateToCompare = calendar.date(from: updatedDateComp)
					
					let todayDateComp = calendar.dateComponents([.year, .month, .day], from: self.date)
					let todayDateToCompare = calendar.date(from: todayDateComp)
					
					if self.segmentedControl.selectedSegmentIndex == 0 {
						// today's offers
						if updatedDateToCompare?.compare(todayDateToCompare!) == ComparisonResult.orderedSame {
							print("Adding one offer for today")
							self.filteredOffersArr.append(offer)
						}
					} else if self.segmentedControl.selectedSegmentIndex == 1 {
						// past offers
						if updatedDateToCompare?.compare(todayDateToCompare!) == ComparisonResult.orderedAscending {
							print("Adding one offer for past")
							self.filteredOffersArr.append(offer)
						}
					}
				}
				
				DispatchQueue.main.async {
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
	
	@IBAction func changeSegmentedControl() {
		self.activityIndicator.activityIndicatorViewStyle = .gray
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
	
		self.database.getAllOffersForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				
				// this array carries all user's offers
				self.offersArr = self.database.convertJSONToOffer(json: json!)
				
				self.dateFormatter.timeZone = TimeZone.autoupdatingCurrent
				self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				
				// clear filtered array first
				self.filteredOffersArr.removeAll()
				
				for offer in self.offersArr {
					let updatedDate = self.dateFormatter.date(from: offer.updatedDateString!)
					
					let calendar = Calendar.init(identifier: .gregorian)
					let updatedDateComp = calendar.dateComponents([.year, .month, .day], from: updatedDate!)
					let updatedDateToCompare = calendar.date(from: updatedDateComp)
					
					let todayDateComp = calendar.dateComponents([.year, .month, .day], from: self.date)
					let todayDateToCompare = calendar.date(from: todayDateComp)
					
					if self.segmentedControl.selectedSegmentIndex == 0 {
						// today's offers
						if updatedDateToCompare?.compare(todayDateToCompare!) == ComparisonResult.orderedSame {
							print("Adding one offer for today")
							self.filteredOffersArr.append(offer)
						}
					} else if self.segmentedControl.selectedSegmentIndex == 1 {
						// past offers
						if updatedDateToCompare?.compare(todayDateToCompare!) == ComparisonResult.orderedAscending {
							print("Adding one offer for past")
							self.filteredOffersArr.append(offer)
						}
					}
				}
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
					self.activityIndicator.stopAnimating()
				}
			}
		}
		
		task.resume()
	}
	
	// MARK: Table view data source
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.filteredOffersArr.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? OffersTableViewCell
		
		// Configure the cell...
		let offer = self.filteredOffersArr[indexPath.row]
		
		cell?.destinationLabel.text = offer.endName!
		cell?.vehicleNameLabel.text = offer.vehicleModel!
		
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
