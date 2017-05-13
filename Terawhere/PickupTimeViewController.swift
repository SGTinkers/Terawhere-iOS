//
//  MeetupTimeViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 13/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

protocol SetTimeProtocol {
	func setTime(hour: Int?, min: Int?)
}

class PickupTimeViewController: UIViewController {

	@IBOutlet var hourTextfield: UITextField!
	@IBOutlet var minTextfield: UITextField!
	
	var delegate: SetTimeProtocol?
	
	var hour = 0, min = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func setMeetupTime() {
		guard let hour = self.hourTextfield.text else {
			print("hour is invalid")
			
			self.dismiss(animated: true, completion: nil)
			
			return
		}
		
		guard let min = self.minTextfield.text else {
			print("min is invalid")
			
			self.dismiss(animated: true, completion: nil)
			
			return
		}
		
		guard let hourInt = Int(hour) else {
			print("hour int is invalid")
			
			self.dismiss(animated: true, completion: nil)
			
			return
		}
		
		guard let minInt = Int(min) else {
			print("min int is invalid")
			
			self.dismiss(animated: true, completion: nil)
			
			return
		}
	
		self.hour = hourInt
		self.min = minInt
		
		self.delegate?.setTime(hour: self.hour, min: self.min)
		self.dismiss(animated: true, completion: nil)
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
