//
//  MapViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit
import SafariServices

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

	@IBOutlet var mapView: MKMapView!
	
	var database = (UIApplication.shared.delegate as! AppDelegate).database
	
	let locationManager = CLLocationManager()
	var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
		
//		self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 73/255, green: 210/255, blue: 175/255, alpha: 1.0)
//		self.tabBarController?.tabBar.barTintColor = UIColor.init(red: 73/255, green: 210/255, blue: 175/255, alpha: 1.0)

		
        // Do any additional setup after loading the view.
		self.mapView.delegate = self
		self.mapView.showsUserLocation = true
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		
		// only update after the user moves 10m
		self.locationManager.distanceFilter = 10
	}

	override func viewWillAppear(_ animated: Bool) {
		// this will trigger another method that will trigger getting all the offers
		// this is for actually getting nearby offers
		print("Hello updating location")
		
		self.locationManager.startUpdatingLocation()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: CLLocationManager delegate
	public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			self.locationManager.requestLocation()
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let userLocation = locations.first {
			self.userLocation = userLocation
			
			print("User location is in")
			
			// putting it here will cause network calls every single update
			// set a distance filter for user location
			// that will solve it
			self.getAllActiveOffersNearMe()
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Unable to get location: \(error)")
	}
	
	// MARK: MKMapView Delegate
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
	
		if annotation is Location {
			let annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pin")
			annotationView.canShowCallout = true
			let button = UIButton.init(type: .detailDisclosure)
			annotationView.rightCalloutAccessoryView = button
			
			return annotationView
		}
		
		return nil
	}
	
	public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		guard let bookRideVC = self.storyboard?.instantiateViewController(withIdentifier: "BookRideViewController") as? BookRideViewController else {
			return
		}
	
		let selectedAnnotation = self.mapView.selectedAnnotations.first as? Location
		
		bookRideVC.database = self.database
		bookRideVC.offer = selectedAnnotation?.offer
		
		
		let navController = UINavigationController.init(rootViewController: bookRideVC)
		self.present(navController, animated: true, completion: nil)
	}
	
	// MARK: Helper functions
	@IBAction func getInfo() {
		guard let url = URL.init(string: "https://terawhere.com") else {
			print("Innvalid url")
			
			return
		}
		
		let alert = UIAlertController.init(title: "Made by MSociety", message: "Would you like to know more?", preferredStyle: .alert)
		let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (action) in
			let safariVC = SFSafariViewController.init(url: url)
			
			self.present(safariVC, animated: true, completion: nil)
		}
		let noAction = UIAlertAction.init(title: "No", style: .default, handler: nil)
		alert.addAction(yesAction)
		alert.addAction(noAction)
		
		self.present(alert, animated: true, completion: nil)
	}
	
	func getAllActiveOffersNearMe() {
		guard let userLocation = userLocation else {
			print("User location is invalid")
			
			return
		}
	
		self.database.getNearbyOffersWith(userLocation: userLocation)
		
		var offerArr = [Offer]()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				let database = Database()
				offerArr = database.convertJSONToOffer(json: json!)
				print("Offer array count \(offerArr.count)")
				
				DispatchQueue.main.async {
					self.mapView?.removeAnnotations((self.mapView?.annotations)!)
					self.mapView?.selectedAnnotations.removeAll()
					
					for offer in offerArr {
						print("Adding offer")
					
						let location = CLLocationCoordinate2D.init(latitude: offer.startLat!, longitude: offer.startLng!)
						
						let annotation = Location.init(withCoordinate: location, AndOffer: offer)
						self.mapView?.addAnnotation(annotation)
					}
					
					guard let userLocation = self.userLocation else {
						print("User location is nil")
						
						return
					}
					
					let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 5000, 5000)
					self.mapView?.setRegion(region, animated: true)
				}
			}
		}
		
		task.resume()
	}
}
