//
//  MeetupTimeViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 13/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

protocol SetTimeProtocol {
	func setTime(date: Date?)
}

class PickupTimeViewController: UIViewController {

	@IBOutlet var datePicker: UIDatePicker!
	
	var delegate: SetTimeProtocol?
	
	var hour = 0, min = 0
	
	var dateFormatter = DateFormatter()
	var date: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		self.date = Date()
		
		self.datePicker.calendar = Calendar.autoupdatingCurrent
		self.datePicker.date = self.date!
		self.datePicker.minimumDate = Date()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func setDateInDatePicker() {
		self.dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
		self.date = self.datePicker.date
	}
	
	@IBAction func setMeetupTime() {
		if let timeSet = self.date {
			self.delegate?.setTime(date: timeSet)
		}

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
