//
//  ViewOfferViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 5/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class ViewOfferViewController: UIViewController {

	var database: Database?
	var offer: Offer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		print("Offer vacancy \((self.offer?.vacancy)!)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func editOffer() {
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
	
	@IBAction func deleteOffer() {
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
    

    /*
    // MARKvar Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
