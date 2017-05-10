//
//  SignInViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

import FacebookCore
import FacebookLogin

class SignInViewController: UIViewController, LoginButtonDelegate {
	
	var facebookLoginButton: LoginButton?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		self.facebookLoginButton = LoginButton(readPermissions: [.publicProfile])
		self.facebookLoginButton?.frame = CGRect.init(x: 10, y: self.view.frame.height / 2, width: self.view.frame.width - 50, height: 50)
		self.view.addSubview(self.facebookLoginButton!)
		self.facebookLoginButton?.delegate = self
	}

	func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
		let database = Database.init(token: (AccessToken.current?.authenticationToken)!, userId: (AccessToken.current?.userId)!)
		database.getUserAuth()
		
		let dataTask = URLSession.shared.dataTask(with: database.request!, completionHandler: { (data, response, error) -> Void in
			if (error != nil) {
				print(error!)
			} else {
				guard let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
					print("JSON invalid")
					
					return
				}
				
				guard let token = json?["token"] as? String else {
					print("No token")
					
					return
				}
				
				print("TOKEN HOORAY \(token)")
				
				let database = Database.init(token: token, userId: (AccessToken.current?.userId)!)
				
				(UIApplication.shared.delegate as! AppDelegate).database = database
				
				DispatchQueue.main.async {
					if let tabBarVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tabBar") as? UITabBarController {
						tabBarVC.selectedIndex = 1
						
						(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(tabBarVC, animated: true, completion: nil)
					}
				}
			}
		})
		
		dataTask.resume()
	}
	
	func loginButtonDidLogOut(_ loginButton: LoginButton) {
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

