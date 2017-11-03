//
//  Location.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/3/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import MapKit
import Contacts

class Location: NSObject, MKAnnotation {
  let title: String?
  let address: String
  let coordinate: CLLocationCoordinate2D
  
  init(title: String, address: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.address = address
    self.coordinate = coordinate
    
    super.init()
  }
  
  var subtitle: String? {
    return address
  }
  
  func mapItem() -> MKMapItem {
    let addressDict = [CNPostalAddressStreetKey: subtitle!]
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    return mapItem
  }
}





