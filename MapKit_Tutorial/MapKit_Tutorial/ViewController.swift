//
//  ViewController.swift
//  MapKit_Tutorial
//
//  Created by Cristian Jaime on 9/14/19.
//  Copyright © 2019 Cristian Jaime. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var destinations: [MKAnnotation]=[]
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentRoute: MKRoute?
    

    @IBOutlet weak var MapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        MapView.delegate = self
        configureLocationServices()
        // Do any additional setup after loading the view.
    }
    
    private func configureLocationServices(){
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse{
            beginLocationUpdates(locationManager: locationManager)
            
        }
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager){
        MapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        MapView.setRegion(region, animated: true)
    }
    
    private func addAnnotations(){
        let MuseoAntro = MKPointAnnotation()
        MuseoAntro.title="Museo de Antropologia"
        MuseoAntro.subtitle="Museo de antropologia e historia"
        MuseoAntro.coordinate=CLLocationCoordinate2D(latitude: 19.2737619, longitude: -99.702382)
        
        destinations.append(MuseoAntro)
        
        MapView.addAnnotation(MuseoAntro)
    }
    
    private func constructRoute(userLocation: CLLocationCoordinate2D){
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        directionsRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinations[0].coordinate))
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate { [weak self] (directionsResponse, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let response = directionsResponse, response.routes.count > 0 {
                
                strongSelf.currentRoute = response.routes[0]
                strongSelf.MapView.addOverlay(response.routes[0].polyline)
                strongSelf.MapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did get latest location")
        
        guard let latestLocation = locations.first else { return }
        
        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
            addAnnotations()
            constructRoute(userLocation: latestLocation.coordinate)
        }
        
        currentCoordinate = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("The status changed")
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let currentRoute = currentRoute else{
            return MKOverlayRenderer()
        }
        
        let polyLineRenderer = MKPolylineRenderer(polyline: currentRoute.polyline)
        polyLineRenderer.strokeColor = UIColor.blue
        
        
        return polyLineRenderer
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("The annotation was selected: \(String(describing: view.annotation?.title))")
    }
}

