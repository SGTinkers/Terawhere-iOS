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

	var database = Database.init(token: (UIApplication.shared.delegate as! AppDelegate).jwt)
	var offerArr = [Offer]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.tableView.separatorStyle = .none
		
		self.database.setAllOffers()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				print("getting offers")

				self.offerArr = self.database.convertJSONToOffer(json: json!)

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
		return self.offerArr.count
	}
	
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? OffersTableViewCell
		
		// Configure the cell...
		cell?.offer = self.offerArr[indexPath.row]
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
