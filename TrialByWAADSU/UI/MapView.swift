//
//  MapView.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
  @Binding var route: Route?

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    mapView.centerToLocation(.msk, regionRadius: 50000)
    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    if let route = route {

      // "Compiler error: Invalid library file" should be ignored.
      // It takes place only in Simulators (it's well known bug).
      // It disappears during testing on real devices.

      mapView.addOverlay(route.multiPolygon)
      mapView.centerToLocation(route.centerLocation, regionRadius: 9000000)
    } else {
      mapView.removeOverlays(mapView.overlays)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView

    func mapView(
      _ mapView: MKMapView,
      rendererFor overlay: MKOverlay
    ) -> MKOverlayRenderer {
      let renderer: MKOverlayRenderer

      switch overlay {
      case is MKMultiPolygon:
        print("Right render")
        let renderer = MKMultiPolygonRenderer(overlay: overlay as! MKMultiPolygon)
        renderer.strokeColor = .orange
        renderer.lineWidth = 3.0
        renderer.alpha = 0.5
        return renderer
      default:
        // other cases were ignored in the name of YAGNI
        renderer = MKOverlayRenderer(overlay: overlay)
      }

      return renderer
    }

    init(_ parent: MapView) {
      self.parent = parent
    }
  }
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance) {
      let coordinateRegion = MKCoordinateRegion(
        center: location.coordinate,
        latitudinalMeters: regionRadius,
        longitudinalMeters: regionRadius)
      setRegion(coordinateRegion, animated: true)
    }
}

private extension CLLocation {
  static var msk: Self {
    .init(latitude: 55.7558, longitude: 37.6173)
  }
}
