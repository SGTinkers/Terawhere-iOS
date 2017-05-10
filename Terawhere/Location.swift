//
//  Location.swift
//  Terawhere
//
//  Created by Muhd Mirza on 30/4/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class Location: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	var title: String? = "Title"
	var offer: Offer?
	
	init(withCoordinate coord: CLLocationCoordinate2D, AndOffer offer: Offer?) {
		self.coordinate = coord
		
		self.offer = offer
		self.title = (self.offer?.startName)!
	}
}
