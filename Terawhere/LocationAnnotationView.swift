//
//  LocationAnnotationView.swift
//  Terawhere
//
//  Created by Muhd Mirza on 29/5/17.
//  Copyright © 2017 msociety. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotationView: MKAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

	/*
		Basically what these two methods do is
		they traverse the view hierarchy
		ask who is supposed to receive touch events
		if one is found, bring that subview to the front
	*/

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let hitView = super.hitTest(point, with: event)
		
		if hitView != nil
		{
			self.superview?.bringSubview(toFront: self)
		}
		
		return hitView;
	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let rect = self.bounds
		var isInside = rect.contains(point)
		
		if isInside == false {
			for view in self.subviews {
				
				isInside = view.frame.contains(point)
				break;
			}
		}
		
		return isInside
	}
}
