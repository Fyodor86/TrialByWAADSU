//
//  Route.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation
import MapKit

struct Route {
  let multiPolygon: MKMultiPolygon
  let distanceInMeters: Double
  let center: MKMapPoint
}

extension Route {
  var distanceInKilometersRounded: Int {
    Int(distanceInMeters / 1000)
  }

  var centerLocation: CLLocation {
    .init(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude)
  }
}

#if DEBUG
extension Route {
  static var mock: Self {
    .init(multiPolygon: .init([]), distanceInMeters: 0, center: .init())
  }
}
#endif

