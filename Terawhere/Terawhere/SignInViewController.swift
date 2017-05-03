//
//  SignInViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		GIDSignIn.sharedInstance().uiDelegate = self
		
		// TODO(developer) Configure the sign-in button look/feel
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func signIn() {
		GIDSignIn.sharedInstance().signIn()
	}
	
	public func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
		let googleSignInVC = UIViewController()
		self.present(googleSignInVC, animated: true, completion: nil)
	}
	
	public func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

