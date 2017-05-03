//
//  SignInViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// the thing about this is that you do not need to set an ibaction to trigger the sign in
		// simply setting the button class in storyboard does it for you
		GIDSignIn.sharedInstance().uiDelegate = self
		
		// TODO(developer) Configure the sign-in button look/feel
		
		let json: [String: Any] = ["created_at": "2017-05-02 15:34",
									"deleted_at": "<null>",
									"end_addr": "Yew tee Point",
									"end_lat": "-90",
									"end_lng": "-180",
									"end_name": "Masjid Yusuf Ishak",
									"id": 2,
									"meetup_time": "2017-05-11 13:23",
									"pref_gender": 0,
									"remarks": "<null>",
									"start_addr": "Sembawang",
									"start_lat": 90,
									"start_lng": 180,
									"start_name": "Ang Mo Kio Hub",
									"updated_at": "2017-05-02 15:34",
									"user_id": 4,
									"vacancy": 3]
		
		
		
		let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		let url = URL.init(string: "http://139.59.224.66/api/v1/offers")
		
		var request = URLRequest.init(url: url!)
		request.httpMethod = "POST"
		request.httpBody = jsonData
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		
		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let response = response {
				print("Response: \(response)")
			}
			
			if let data = data {
				if let dataHello = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) {
					print("Data hello: \(dataHello)")
				}
			}
		}
		task.resume()

//		let url = URL.init(string: "http://139.59.224.66/api/v1/offers")
//		let request = URLRequest.init(url: url!)
//		
//		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
//				print(json)
//			}
//		}
//		
//		task.resume()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

