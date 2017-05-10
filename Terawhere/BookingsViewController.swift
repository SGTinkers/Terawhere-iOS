//
//  BookingViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 10/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class BookingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!
	@IBOutlet var segmentedControl: UISegmentedControl!
	
	var database = (UIApplication.shared.delegate as! AppDelegate).database
	var bookingArr = [Booking]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.separatorStyle = .none
    }
	
	override func viewWillAppear(_ animated: Bool) {
		self.database.getAllBookings()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				print("JSON \(json!)")
			
				self.bookingArr = self.database.convertJSONToBooking(json: json!)
				
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
    

	// MARK: Table view data source
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.bookingArr.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookingsTableViewCell
		
		// Configure the cell...
		cell?.booking = self.bookingArr[indexPath.row]
		cell?.title.text = "Booking: \((self.bookingArr[indexPath.row].offerId)!)"
		
		return cell!
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
