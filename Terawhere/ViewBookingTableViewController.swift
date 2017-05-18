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
	
	var tableItems = ["Meet pt name", "Meet pt", "Driver name", "No. of pax left", "Car model", "Vehicle no.", "Pick up time", "Destination"]
	
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
		print("View: Booking id: \((self.booking?.id)!)")
		self.database?.cancel(booking: self.booking)
		
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
		
		if indexPath == self.meetupPointNameIndexPath {
			cell.detailTextLabel?.text = String((offer?.startName)!)
		}
		
		if indexPath == self.meetupPointIndexPath {
			cell.detailTextLabel?.text = String((offer?.startAddr)!)
		}
		
		if indexPath == self.driverNameIndexPath {
			cell.detailTextLabel?.text = String((offer?.name)!)
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

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
