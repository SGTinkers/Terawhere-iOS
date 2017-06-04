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
	
	@IBOutlet var destinationLabel: UILabel!
	@IBOutlet var meetupLabel: UILabel!
	@IBOutlet var vacancyLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		self.mapView.delegate = self
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
			let annotationView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: "pin")
			
			let image = UIImage.init(named: "car_pin")
			
			// resize image using a new image graphics context
			UIGraphicsBeginImageContextWithOptions(CGSize.init(width: 30, height: 40), false, 0.0)
			image?.draw(in: CGRect.init(x: 0, y: 0, width: 30, height: 40))
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			annotationView.image = newImage
			
			return annotationView
		}
		
		return nil
	}

}
