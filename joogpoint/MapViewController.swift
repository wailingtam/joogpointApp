//
//  MapViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 7/8/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import Locksmith
import SwiftyJSON

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentAnnotations = [MKAnnotation]()
    
    var firstRun: Bool = true
    
    // MARK: - location manager to authorize user location for Maps app
    var locationManager = CLLocationManager()
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /*
    var focusEstablishment: Establishment? {
        didSet {
            configureView()
        }
    }
    */
    /*
     override func viewWillAppear(animated: Bool) {
     super.viewWillAppear(animated)
     self.navigationController?.navigationBarHidden = true
     self.navigationController?.setNavigationBarHidden(true, animated: true)
     }
     */
    /*
    func configureView() {
        if let establishment = focusEstablishment {
            centerMapOnLocation(CLLocation(latitude: establishment.coordinate.latitude, longitude: establishment.coordinate.longitude))
        }
    }
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        
        if self.tabBarController != nil {
        }
        
        loadEstablishments {response in
            self.currentAnnotations = response
            self.mapView.addAnnotations(response)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstRun = true
        // set initial location in Barcelona
        let initialLocation = CLLocation(latitude: 41.387015, longitude: 2.169908)
        
        // remove later
        centerMapOnLocation(initialLocation)
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        mapView.delegate = self
        
//        configureView()
        
//        loadEstablishments {response in
//            self.mapView.addAnnotations(response)
//        }
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        if (firstRun) {
            centerMapOnLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
            firstRun = false
        }
    }
    
    func loadEstablishments(completion : (Array<Establishment>) -> ()){
        
        var establishments = [Establishment]()
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]

         Alamofire.request(.GET, "https://joogpoint.herokuapp.com/establishments/", headers: headers)
             .validate()
             .responseJSON { response in
                switch response.result {
                case .Success:
                    
                    self.mapView.removeAnnotations(self.currentAnnotations)
                    
                    if let data = response.result.value {
                        let json = JSON(data)
                        for (_, subJson):(String, JSON) in json["results"] {
                            establishments.append(Establishment(url: subJson["url"].string!, name: subJson["name"].string!, address: subJson["address"].string!, postcode: subJson["postcode"].string!, city: subJson["city"].string!, country: subJson["country"].string!, coordinate: CLLocationCoordinate2D(latitude: subJson["latitude"].double!, longitude: subJson["longitude"].double!), playlistUrl: subJson["establishment_playlist"].string!))
                        }
                    }
                    completion(establishments)
                    
                case .Failure(let error):
                    print(error)
             }
         }
        
    }
    
    // Specify the rectangular region to display to get a correct zoom level 
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}