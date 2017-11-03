//
//  Location.swift
//  DGB-Calendar
//
//  Created by Nicholas Soffa on 11/3/17.
//  Copyright © 2017 Nicholas Soffa. All rights reserved.
//

import MapKit

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
}
