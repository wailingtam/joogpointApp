//
//  VCMapView.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 25/08/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    // Method that gets called for every annotation you add to the map to return the view for each annotation.
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Establishment {
            let identifier = "pin"
            var view: MKPinAnnotationView
            // Reuse annotation views when some are no longer visible
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                view.pinTintColor = UIColor.blueColor()
            }
            
            return view
        }
        return nil
    }
    
    // Segue to establishment profile
    func mapView (mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        self.performSegueWithIdentifier("ShowEstablishmentDetail", sender: view)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowEstablishmentDetail" {
            let nextViewController = segue.destinationViewController as! EstablishmentProfileViewController
            nextViewController.establishment = (sender?.annotation!)! as? Establishment
        }
    }

}