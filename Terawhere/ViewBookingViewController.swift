//
//  ViewBookingViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 6/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class ViewBookingViewController: UIViewController {

	var database: Database?
	var booking: Booking?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func cancelBooking() {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
