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
import CloudKit

class ViewInfoViewController: UIViewController {
  
  @IBOutlet weak var eventInfoTableView: UITableView!

  var eventDate: String?
  var eventRecord: CKRecord?
  var clientRecord: CKRecord?
  var clientRecords: [CKRecord]?
  var dogRecords: [CKRecord]?
  var dogRecord: CKRecord?
  
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
        editVC.eventRecord = eventRecord
        editVC.clientRecord = clientRecord
        editVC.dogRecord = dogRecord
        editVC.dogRecords = dogRecords!
        editVC.clientRecords = clientRecords!
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
    DispatchQueue.main.async {
      self.eventInfoTableView.reloadData()
    }
  }
  
  func centerMapOnLocation(cell: MapViewCell) {
    let geocoder = CLGeocoder()
    let eventAddress = eventRecord?.value(forKey: "Address") as! String
    geocoder.geocodeAddressString(eventAddress) { (placemarks, error) in
      guard
        let placemarks = placemarks,
        let location = placemarks.first?.location
        else {
          return
      }
      let spotOnMap = Location(title: "Client Address", address: eventAddress, coordinate: location.coordinate)
      let coordinateRegion = MKCoordinateRegionMakeWithDistance(spotOnMap.coordinate, self.regionRadius, self.regionRadius)
      cell.mapView.addAnnotation(spotOnMap)
      cell.mapView.setRegion(coordinateRegion, animated: true)
    }
  }
  
  func getDog(eventRecord: CKRecord) -> CKRecord {
    var dog: CKRecord?
    for dogRecord in dogRecords! {
      let eventDogReference = eventRecord.value(forKey: "DogReference") as! CKReference
      let eventDogRecordName = eventDogReference.recordID.recordName
      if eventDogRecordName == dogRecord.recordID.recordName {
        dog = dogRecord
      }
    }
    return dog!
  }
  
}

extension ViewInfoViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 6
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 3 {
      return 266.0
    } else {
      return UITableViewAutomaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Client Name:"
      cell.detailText.text = clientRecord?.value(forKey: "Name") as! String
      return cell
    } else if indexPath.row == 1 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Dog:"
      dogRecord = getDog(eventRecord: eventRecord!)
      cell.detailText.text = dogRecord?.value(forKey: "Name") as! String
      return cell
    } else if indexPath.row == 2 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Address:"
      cell.detailText.text = eventRecord?.value(forKey: "Address") as! String
      return cell
    } else if indexPath.row == 3 {
      let cell: MapViewCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! MapViewCell
      centerMapOnLocation(cell: cell)
      cell.mapView.mapRectThatFits(cell.mapView.visibleMapRect)
      return cell
    } else if indexPath.row == 4 {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Time:"
      cell.detailText.text = eventRecord?.value(forKey: "Time") as! String
      return cell
    } else {
      let cell: DetailCell = eventInfoTableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
      cell.titleText.text = "Notes:"
      cell.detailText.text = eventRecord?.value(forKey: "Notes") as! String
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



















