//
//  MapViewController.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

import Firebase
import FirebaseDatabase

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

	@IBOutlet var mapView: MKMapView!

	var ref: FIRDatabaseReference?
	
	let locationManager = CLLocationManager()
	
	var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.ref = FIRDatabase.database().reference()
		
		self.mapView.delegate = self
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.requestLocation()
		
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
			self.userLocation = userLocation
		}
	}
	
	public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Unable to get location: \(error)")
	}
	
	// MARK: MKMapView Delegate
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is Location {
			let annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pin")
			annotationView.canShowCallout = true
			let button = UIButton.init(type: .detailDisclosure)
			annotationView.rightCalloutAccessoryView = button
		}
		
		return nil
	}
	
	// MARK: Helper functions
	func getAllActiveOffersNearMe() {
		self.mapView.removeAnnotations(self.mapView.annotations)
		self.mapView.selectedAnnotations.removeAll()
		
		self.ref?.child("rides").observeSingleEvent(of: .value, with: { (snapshot) in
			for child in snapshot.children {
				if let childSnapshot = child as? FIRDataSnapshot {
					self.ref?.child("rides/\(childSnapshot.key)/destination/location/l").observeSingleEvent(of: .value, with: { (snapshot) in
						if let value = snapshot.value as? [Double] {
							let lat = value[0]
							let long = value[1]
							
							print(value[0])
							print(value[1])
							
							let location = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
							
							let annotation = Location.init(withCoordinate: location, andTitle: "Hello")
							self.mapView.addAnnotation(annotation)
						}
					})
				}
				
				// second entry is invalid
				break
			}
		})
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
