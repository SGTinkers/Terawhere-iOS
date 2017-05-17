//
//  OffersTableViewCell.swift
//  Terawhere
//
//  Created by Muhd Mirza on 1/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class OffersTableViewCell: UITableViewCell, MKMapViewDelegate {

	@IBOutlet var mapView: MKMapView!
	
	@IBOutlet var pickupLocationLabel: UILabel!
	@IBOutlet var destinationLabel: UILabel!
	@IBOutlet var pickupTimeLabel: UILabel!
	@IBOutlet var vacancyLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	// MARK: MKMapView Delegate
	public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if annotation is MKUserLocation {
			return nil
		}
		
		if annotation is Location {
			let annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "pin")
			
			return annotationView
		}
		
		return nil
	}

}
