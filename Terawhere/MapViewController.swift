//
//  MapViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

	@IBOutlet var mapView: MKMapView!
	
	var database = Database.init(token: (UIApplication.shared.delegate as! AppDelegate).jwt)
	
	let locationManager = CLLocationManager()
	var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		self.mapView.delegate = self
		self.mapView.showsUserLocation = true
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.distanceFilter = 1000 // only update after the user moves 1000m
		
		// this will trigger another method that will trigger getting all the offers
		// this is for actually getting nearby offers
		self.locationManager.startUpdatingLocation()
	}

	override func viewWillAppear(_ animated: Bool) {
		// put this here for testing purposes
		// you do not need the user location here
		self.getAllActiveOffersNearMe()
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
			print("Updating user location")
		
			self.userLocation = userLocation
			
			// putting it here will cause network calls every single update
			// set a distance filter for user location
			// that will solve it
//			self.getAllActiveOffersNearMe()
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
		
		self.navigationController?.pushViewController(bookRideVC, animated: true)
	}
	
	// MARK: Helper functions
	func getAllActiveOffersNearMe() {
		self.database = Database.init(token: (UIApplication.shared.delegate as! AppDelegate).jwt)
		self.database.setAllOffers()
		
		var offerArr = [Offer]()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
				print("getting offers")
				
				let database = Database()
				offerArr = database.convertJSONToOffer(json: json!)
				
				print("Array count!! \(offerArr.count)")
				
				DispatchQueue.main.async {
					self.mapView?.removeAnnotations((self.mapView?.annotations)!)
					self.mapView?.selectedAnnotations.removeAll()
					
					for offer in offerArr {
						let location = CLLocationCoordinate2D.init(latitude: offer.startLat!, longitude: offer.startLng!)
						
						let annotation = Location.init(withCoordinate: location, andTitle: offer.startName!)
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

//	func reloadMap() {
//		for annotation in self.mapView.annotations {
//			if annotation is Location {
//				// basically fits in 1000m worth of latitude area for user to see on the map
//				let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 0)
//				
//				self.mapView.setRegion(region, animated: true)
//			}
//		}
//	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
