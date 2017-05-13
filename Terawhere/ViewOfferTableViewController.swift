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
	
	var tableItems = ["Meeting point", "Driver name", "No. of pax left", "Car model", "Vehicle no.", "Pick up time", "Destination"]
	
	var meetupPointIndexPath = IndexPath.init(row: 0, section: 0)
	var driverNameIndexPath = IndexPath.init(row: 1, section: 0)
	var vacancyIndexPath = IndexPath.init(row: 2, section: 0)
	var carModelIndexPath = IndexPath.init(row: 3, section: 0)
	var vehicleNumberIndexPath = IndexPath.init(row: 4, section: 0)
	var pickupTimeIndexPath = IndexPath.init(row: 5, section: 0)
	var destinationIndexPath = IndexPath.init(row: 6, section: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func displayOptions() {
		let alert = UIAlertController.init(title: "", message: "", preferredStyle: .actionSheet)
		let delete = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
			self.deleteOffer()
		}
		let edit = UIAlertAction.init(title: "Edit", style: .default) { (action) in
			self.editOffer()
		}
		
		alert.addAction(delete)
		alert.addAction(edit)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func editOffer() {
		self.database?.edit(offer: self.offer)
		
		let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
				print(json)
			} else {
				print("No JSON")
			}
		}
		
		dataTask.resume()
	}
	
	func deleteOffer() {
		self.database?.delete(offer: self.offer)
		
		let dataTask = URLSession.shared.dataTask(with: (self.database?.request)!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
				print(json)
				
				DispatchQueue.main.async {
					self.tabBarController?.navigationController?.popViewController(animated: true)
				}
			}
		}
		
		dataTask.resume()
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
		
		if indexPath == self.meetupPointIndexPath {
			cell.detailTextLabel?.text = String((offer?.startName)!)
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
			cell.detailTextLabel?.text = String((offer?.vacancy)!)
		}
		
		if indexPath == self.carModelIndexPath {
			cell.detailTextLabel?.text = (offer?.vehicleModel)!
		}
		
		if indexPath == self.vehicleNumberIndexPath {
			cell.detailTextLabel?.text = String((offer?.vehicleNumber)!)
		}
		
		if indexPath == self.pickupTimeIndexPath {
			cell.detailTextLabel?.text = (offer?.meetupTime)!
		}
		
		if indexPath == self.destinationIndexPath {
			cell.detailTextLabel?.text = String((offer?.endName)!)
		}

		return cell
	}

//	
//	// MARK: tableview delegate
//	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		guard let viewOfferVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewOfferViewController") as? ViewOfferViewController else {
//			print("View offer VC errors out")
//			
//			return
//		}
//		
//		let offer = self.filteredOffersArr[indexPath.row]
//		viewOfferVC.offer = offer
//		viewOfferVC.database = self.database
//		
//		self.navigationController?.pushViewController(viewOfferVC, animated: true)
//	}
	

    /*
     MARKvar Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         Get the new view controller using segue.destinationViewController.
         Pass the selected object to the new view controller.
    }
    */

}
