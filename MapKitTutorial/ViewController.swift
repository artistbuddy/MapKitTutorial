//
//  ViewController.swift
//  MapKitTutorial
//
//  Created by Karol on 13/03/2017.
//  Copyright © 2017 Karol Bukowski. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var destinationSearchBarContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedPin: MKPlacemark? = nil
    
    let locationManager = CLLocationManager()
    var destinationSearchController: UISearchController? = nil
    var beginningSearchController: UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()

        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        destinationSearchController = UISearchController(searchResultsController: locationSearchTable)
        destinationSearchController?.searchResultsUpdater = locationSearchTable

                
        let destinationSearchBar = destinationSearchController?.searchBar
        destinationSearchBar?.autoresizingMask = [.flexibleWidth]
        destinationSearchBar?.sizeToFit()
        assert(destinationSearchBar != nil)
        destinationSearchBarContainer.addSubview(destinationSearchBar!)
        
//        destinationSearchController?.hidesNavigationBarDuringPresentation = false
//        destinationSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        


    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.02, 0.02)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}
