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

import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	var database = (UIApplication.shared.delegate as! AppDelegate).database
	
	let alert = UIAlertController.init(title: "", message: "", preferredStyle: .alert)

	var mapView: GMSMapView?
	
	let locationManager = CLLocationManager()
	var userLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
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
		
		
		self.alert.title = "Getting user location.."
		self.present(self.alert, animated: true, completion: nil)
		
		
		self.activityIndicator.hidesWhenStopped = true
		self.activityIndicator.startAnimating()
		
		self.locationManager.requestLocation()
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
	
		self.alert.title = "Getting nearby offers.."
		self.database.getNearbyOffersWith(userLocation: userLocation)
		
		var offerArr = [Offer]()
		
		let task = URLSession.shared.dataTask(with: self.database.request!) { (data, response, error) in
			if let error = error {
				print("Getting nearby offers error: \(error)")
			} else {
				if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?] {
					let database = Database()
					offerArr = database.convertJSONToOffer(json: json!)
					print("Offer array count \(offerArr.count)")
					
					DispatchQueue.main.async {
						let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 10.0)
						self.mapView = GMSMapView.map(withFrame: .zero, camera: camera)
						self.mapView?.delegate = self
						self.view = self.mapView
						
						for offer in offerArr {
							print("Adding offer")
							
							let coord = CLLocationCoordinate2D.init(latitude: offer.startLat!, longitude: offer.startLng!)
							let location = Location.init(withCoordinate: coord, AndOffer: offer)
							
							let marker = GMSMarker()
							marker.position = CLLocationCoordinate2D(latitude: offer.startLat!, longitude: offer.startLng!)
							marker.title = "Test"
							marker.snippet = "Hello"
							marker.icon = UIImage.init(named: "car_pin")
							marker.userData = location
							marker.map = self.mapView
						}
						
						self.alert.dismiss(animated: true, completion: nil)
						self.activityIndicator.stopAnimating()
					}
				}
			}
		}
		
		task.resume()
	}
	
	// MARK: Google maps delegate
	public func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
		marker.tracksInfoWindowChanges = true
	
		let dateHelper = DateHelper()
	
		let views = Bundle.main.loadNibNamed("CustomCalloutView", owner: nil, options: nil)
		let customCalloutView = views?.first as! CustomCalloutView
		
		let userData = marker.userData as? Location
		
		
		customCalloutView.destinationLabel.text = (userData?.offer?.endAddr)!
		
		let localMeetupTime = dateHelper.localTimeFrom(dateString: (userData?.offer?.meetupTime)!)
		customCalloutView.pickupTimeLabel.text = localMeetupTime
		
		var bookingsArr = [Booking]()
		
		self.database.getAllBookingsForOfferByOffer(id: (userData?.offer?.offerId)!)
		let dataTask = URLSession.shared.dataTask(with: self.database.request!, completionHandler: { (data, response, error) in
			let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any?]
			bookingsArr = self.database.convertJSONToBooking(json: json!!)
			
			var paxBooked = 0
			
			for booking in bookingsArr {
				paxBooked = paxBooked + booking.paxBooked!
			}
			
			DispatchQueue.main.async {
				let vacancy = (userData?.offer?.vacancy)! - paxBooked
				
				customCalloutView.seatsLeftLabel.text = String(vacancy)
			}
		})
		
		dataTask.resume()
		
		return customCalloutView
	}
	
	public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
		guard let bookRideVC = self.storyboard?.instantiateViewController(withIdentifier: "BookRideViewController") as? BookRideViewController else {
			return
		}
		
		let selectedAnnotation = self.mapView?.selectedMarker?.userData as? Location
		
		bookRideVC.database = self.database
		bookRideVC.offer = selectedAnnotation?.offer
		
		
		let navController = UINavigationController.init(rootViewController: bookRideVC)
		self.present(navController, animated: true, completion: nil)
	}
}
