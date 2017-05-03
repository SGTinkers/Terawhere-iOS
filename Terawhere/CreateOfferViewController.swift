//
//  CreateOfferViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 1/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

class CreateOfferViewController: UIViewController, UITextFieldDelegate {
	
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var textfieldOne: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.textfieldOne.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	public func textFieldDidBeginEditing(_ textField: UITextField) {
		let point = CGPoint.init(x: 0, y: textField.frame.origin.y)
		self.scrollView.setContentOffset(point, animated: true)
	}
	
	public func textFieldDidEndEditing(_ textField: UITextField) {
		self.scrollView.setContentOffset(.zero, animated: true)
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
