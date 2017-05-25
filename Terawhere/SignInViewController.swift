//
//  SignInViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import CoreData

import FacebookCore
import FacebookLogin

class SignInViewController: UIViewController, LoginButtonDelegate {
	
	var facebookLoginButton: LoginButton?
	
	var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		let request = NSFetchRequest<User>.init(entityName: "User")
		let items = try? self.context.fetch(request)
		
		if let user = items?.first {
			if let token = user.token, let userId = user.userId {
				let database = Database.init(token: token, userId: userId)
				database.getUserAuth()
				
				let dataTask = URLSession.shared.dataTask(with: database.request!, completionHandler: { (data, response, error) -> Void in
					if (error != nil) {
						print(error!)
					} else {
						let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
						print("Sign in json \(json)")
						
						
						
						
						if let token = json??["token"] as? String {
							print("TOKEN GOOD TO GO \(token)")
							
							let database = Database.init(token: token, userId: userId)
							
							(UIApplication.shared.delegate as! AppDelegate).database = database
							
							DispatchQueue.main.async {
								if let tabBarVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tabBar") as? UITabBarController {
									tabBarVC.selectedIndex = 1
									
									(UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(tabBarVC, animated: true, completion: nil)
								}
							}
						}
						
						
						
						if let _ = json??["token_expire"] {
							print("TOKEN EXPIRED, REFRESHING..")
							
							// delete item from context
							self.context.delete((items?.first)!)
							
							do {
								try self.context.save()
							} catch {
								print("Context item delete fail")
							}
						
							// refresh token
							var database = Database.init(token: token, userId: userId)
							database.refreshToken()
							
							let dataTask = URLSession.shared.dataTask(with: database.request!, completionHandler: { (data, response, error) in
								let json = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
								
								guard let token = json??["token"] as? String else {
									print("No token")
									
									return
								}
								
								// insert new item into context
								let item = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.context) as? User
								item?.token = token
								item?.userId = userId
								
								do {
									try self.context.save()
								} catch {
									print("Context item insert fail")
								}
								
								
								// init a new database with new token and existing user id
								database = Database.init(token: token, userId: userId)
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
							})
							
							dataTask.resume()
						}
						
						
						
						
						
						
						
						if let _ = json??["token_invalid"] {
							print("TOKEN EXPIRED, SHOWING SIGN IN BUTTON..")
							
							// delete item from context
							self.context.delete((items?.first)!)
							
							do {
								try self.context.save()
							} catch {
								print("Context item delete fail")
							}
							
							DispatchQueue.main.async {
								let width: CGFloat = 300
								let height: CGFloat = 50
								
								self.facebookLoginButton = LoginButton(readPermissions: [.publicProfile])
								self.facebookLoginButton?.frame = CGRect.init(x: (self.view.frame.width / 2) - (width / 2), y: CGFloat(self.view.frame.height - 180), width: width, height: height)
								self.view.addSubview(self.facebookLoginButton!)
								self.facebookLoginButton?.delegate = self
							}
						}
					}
				})
				
				dataTask.resume()
			}
		} else {
			let width: CGFloat = 300
			let height: CGFloat = 50
			
			self.facebookLoginButton = LoginButton(readPermissions: [.publicProfile])
			self.facebookLoginButton?.frame = CGRect.init(x: (self.view.frame.width / 2) - (width / 2), y: CGFloat(self.view.frame.height - 180), width: width, height: height)
			self.view.addSubview(self.facebookLoginButton!)
			self.facebookLoginButton?.delegate = self
		}
	}

	func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
		// insert new item into context
		let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.context) as? User
		user?.token = (AccessToken.current?.authenticationToken)!
		user?.userId = (AccessToken.current?.userId)!
		
		do {
			try self.context.save()
			
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
		} catch {
			print("Failed to save sign in details to context")
		}
	}
	
	func loginButtonDidLogOut(_ loginButton: LoginButton) {
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
}

