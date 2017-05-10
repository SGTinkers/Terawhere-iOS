//
//  OffersViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 1/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class OffersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var segmentedControl: UISegmentedControl!

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
		self.filteredOffersArr.removeAll()
	
		self.database.getAllOffersForUser()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				print("getting offers")
				
				print("JSON \(json!)")
				
				// this array carries all user's offers
				self.offersArr = self.database.convertJSONToOffer(json: json!)
				
				self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
				self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

				for offer in self.offersArr {
					let updatedDate = self.dateFormatter.date(from: offer.updatedDateString!)
					
					// basic run down
					// get the date components from the two date objects
					// make a new date object based only on year, month and day
					// compare the two dates
					
					let calendar = Calendar.current
					let updatedDateComp = calendar.dateComponents([.year, .month, .day], from: updatedDate!)
					let updatedDateToCompare = calendar.date(from: updatedDateComp)
					
					let todayDateComp = calendar.dateComponents([.year, .month, .day], from: self.date)
					let todayDateToCompare = calendar.date(from: todayDateComp)
					
					
					
					// today's offers
					if updatedDateToCompare?.compare(todayDateToCompare!) == ComparisonResult.orderedSame {
						print("Adding one offer for today")
						self.filteredOffersArr.append(offer)
					}
				}
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
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
		// clear filtered array first
		self.filteredOffersArr.removeAll()
	
		self.dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
		self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		for offer in self.offersArr {
			let updatedDate = self.dateFormatter.date(from: offer.updatedDateString!)
			
			
			let calendar = Calendar.current
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
					print("Adding one offer for today")
					self.filteredOffersArr.append(offer)
				}
			}
		}
		
		self.tableView.reloadData()
	}
	
	// MARK: Table view data source
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.filteredOffersArr.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? OffersTableViewCell
		
		// Configure the cell...
		cell?.offer = self.filteredOffersArr[indexPath.row]
		cell?.title.text = (cell?.offer?.startName)!
		
		return cell!
	}

	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	// MARK: tableview delegate
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let viewOfferVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewOfferViewController") as? ViewOfferViewController else {
			print("View offer VC errors out")
			
			return
		}
		
		self.navigationController?.pushViewController(viewOfferVC, animated: true)
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
