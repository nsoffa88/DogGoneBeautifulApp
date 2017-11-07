//
//  ViewInfoViewController.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 10/26/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewInfoViewController: UIViewController {
  
  @IBOutlet weak var eventInfoTableView: UITableView!

  var eventDate: String?
  var event: Event?
  
  let regionRadius: CLLocationDistance = 1000

  override func viewDidLoad() {
    super.viewDidLoad()
    
    eventInfoTableView.estimatedRowHeight = 50
    eventInfoTableView.rowHeight = UITableViewAutomaticDimension
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "editEventSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let editVC = destinationNavController.topViewController as? AddEventViewController {
        editVC.newEvent = false
        editVC.eventDate = eventDate
        editVC.event = event
      }
    }
    if segue.identifier == "infoToCalendarSegue" {
      let destinationNavController = segue.destination as! UINavigationController
      if let calendarVC = destinationNavController.topViewController as? CalendarView {
        calendarVC.selectedDate = eventDate
      }
    }
  }
  
  @IBAction func doneSavingEvent(_ segue: UIStoryboardSegue) {
    eventInfoTableView.reloadData()
  }
  
  func centerMapOnLocation(cell: MapViewCell) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString((event?.location)!) { (placemarks, error) in
      guard
        let placemarks = placemarks,
        let location = placemarks.first?.location
        else {
          return
      }
      let spotOnMap = Location(title: "Client Address", address: (self.event?.location)!, coordinate: location.coordinate)
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(spotOnMap.coordinate, self.regionRadius, self.regionRadius)
      cell.mapView.addAnnotation(spotOnMap)
      cell.mapView.setRegion(coordinateRegion, animated: true)
    }
  }
  
}

extension ViewInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Event.entity().attributesByName.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 2 {
      return 266.0
    } else {
      return UITableViewAutomaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Client Name:"
      cell.detailText.text = event?.eventClientName
      return cell
    } else if indexPath.row == 1 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Address:"
      cell.detailText.text = event?.location
      return cell
    } else if indexPath.row == 2 {
      let cell: MapViewCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapViewCell
      centerMapOnLocation(cell: cell)
      cell.mapView.mapRectThatFits(cell.mapView.visibleMapRect)
      return cell
    } else if indexPath.row == 3 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Time:"
      cell.detailText.text = event?.time
      return cell
    } else {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Notes:"
      cell.detailText.text = event?.notes
      return cell
    }
  }
}

extension ViewInfoViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? Location else { return nil }
    let identifier = "marker"
    var view: MKMarkerAnnotationView
    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
      dequeuedView.annotation = annotation
      view = dequeuedView
    } else {
      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      view.canShowCallout = true
      view.calloutOffset = CGPoint(x: 0, y: 5)
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    return view
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    let location = view.annotation as! Location
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    location.mapItem().openInMaps(launchOptions: launchOptions)
  }
}



















