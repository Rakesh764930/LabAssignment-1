//
//  ViewController.swift
//  LabAssignment_1
//
//  Created by MacStudent on 2020-01-14.
//  Copyright © 2020 MacStudent. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

@IBOutlet weak var mapView: MKMapView!
var locationManager = CLLocationManager()
var userLoc=CLLocationCoordinate2D()
var destLoc=CLLocationCoordinate2D()


override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
   
    
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
    let userLocation: CLLocation = locations[0]
    
    // getting latitude and longitude
    let lat = userLocation.coordinate.latitude
    let long = userLocation.coordinate.longitude
    
    // getting deltas for span
    let latDelta : CLLocationDegrees = 0.05
    let longDelta : CLLocationDegrees = 0.05
           
    // setting span and location
    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
    userLoc = CLLocationCoordinate2D(latitude: lat, longitude: long)
           
    // setting region
    let region = MKCoordinateRegion(center: userLoc, span: span)
    mapView.setRegion(region, animated: true)
    
    // add double tap gesture
    let uitpgr = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture))
    uitpgr.numberOfTapsRequired = 2
    mapView.addGestureRecognizer(uitpgr)
   
    
}

@objc func doubleTapGesture(gestureRecognizer: UIGestureRecognizer){
    
    let touchPoint = gestureRecognizer.location(in: mapView)
  destLoc = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    
    let annotation = MKPointAnnotation()
    annotation.title = "MY Destination"
    annotation.coordinate = destLoc
if mapView.annotations.count == 1 {
       
           mapView.addAnnotation(annotation)
           
       } else {
           
           mapView.removeAnnotations(mapView.annotations)
           mapView.addAnnotation(annotation)
       }
    }

@objc func navigation(transType:MKDirectionsTransportType) {
 let placeMark1=MKPlacemark(coordinate: userLoc)
       let placeMark2=MKPlacemark(coordinate: destLoc)
    let request = MKDirections.Request()
    
          request.source = MKMapItem( placemark: placeMark1)
          request.destination = MKMapItem(placemark: placeMark2)
// for alternate routes
          //request.requestsAlternateRoutes = true
    request.transportType=transType


          let directions = MKDirections(request: request)

          directions.calculate {  (response, error) in
              guard let directionResponse = response else { return }

              for route in directionResponse.routes {
                  self.mapView.addOverlay(route.polyline)
                self.mapView.delegate = self
                  self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
              }
          }
    
}

    @IBAction func navigateFMY(_ sender: Any) {
        mapView.removeOverlays(mapView.overlays)
           navigation(transType: .automobile)
    }
    
@IBAction func navigateIcon(_ sender: UIButton) {
        mapView.removeOverlays(mapView.overlays)
     navigation(transType: .automobile)
}


  
    @IBAction func zoomInBtn(_ sender: Any) {
    
    let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta*2, longitudeDelta: mapView.region.span.longitudeDelta*2)
           let region = MKCoordinateRegion(center: mapView.region.center, span: span)
           
           mapView.setRegion(region, animated: true)
       }
       
   
    
    @IBAction func zoomOutBtn(_ sender: Any) {
    
    
           let span = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta/2, longitudeDelta: mapView.region.span.longitudeDelta/2)
           let region = MKCoordinateRegion(center: mapView.region.center, span: span)
           
           mapView.setRegion(region, animated: true)
       }
@IBAction func car(_ sender: UIButton) {
    
    mapView.removeOverlays(mapView.overlays)
     navigation(transType: .automobile)
    
}
@IBAction func walk(_ sender: UIButton) {
           mapView.removeOverlays(mapView.overlays)
     navigation(transType: .walking)
}

}
extension ViewController : MKMapViewDelegate
{
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
    renderer.strokeColor = UIColor.blue
    renderer.lineWidth=6.0
    return renderer
}


}
