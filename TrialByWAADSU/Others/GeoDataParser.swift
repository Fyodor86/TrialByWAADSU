//
//  GeoDataParser.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation
import CodableGeoJSON
import MapKit

protocol GeoDataParser {
  func parse(data: Data) async throws -> Route
}

// Performs data conversion from JSON into `Route`.
// Uses CodableGeoJSON insted of MKGeoJSONDecoder because the given JSON has 14 incorrect values
// (longitude = 180.00000000000017)
// and MKGeoJSONDecoder fails to decode date.

final class GeoDataParserImp: GeoDataParser {
  func parse(data: Data) async throws -> Route {
    let result = await Task.init(priority: .userInitiated) {
      syncParse(data: data)
    }.value

    switch result {
    case .success(let route):
      return route
    case .failure(let error):
      throw error
    }
  }

  private func syncParse(data: Data) -> Result<Route, AppError> {
    guard let geoJSON = try? JSONDecoder().decode(GeoJSON.self, from: data),
          let multiPolygoneCoordinates = extractCoordinates(fromGeoJSON: geoJSON)
    else {
      return .failure(.parseError)
    }

    // polygons, distance and center extraction could be performed in a single loop
    // but was left in separate ones for readability

    let multiPolygone = createMKMultiPoligon(from: multiPolygoneCoordinates)
    let distance = calculateDistance(from: multiPolygoneCoordinates)
    let center = resolveCenter(from: multiPolygoneCoordinates)

    return .success(.init(multiPolygon: multiPolygone, distanceInMeters: distance, center: center))
  }

  private func extractCoordinates(fromGeoJSON geoJSON: GeoJSON) -> MultiPolygonGeometry.Coordinates? {
    guard case let .featureCollection( featureCollection, _) = geoJSON,
          !featureCollection.features.isEmpty,
          case let .multiPolygon(coordinates) = featureCollection.features[0].geometry
    else {
      return nil
    }
    return coordinates
  }

  private func createMKMultiPoligon(from coordinates: MultiPolygonGeometry.Coordinates) -> MKMultiPolygon {
    .init(coordinates.reduce(into: [MKPolygon]()) { result, polygonCoordinates in
      result.append(createMKPolygon(from: polygonCoordinates))
    })
  }

  private func createMKPolygon(from coordinates: PolygonGeometry.Coordinates) -> MKPolygon {
    var points: [CLLocationCoordinate2D] = []

    coordinates.forEach { positions in
      positions.forEach { position in
        if abs(position.latitude) <= 90 && abs(position.longitude) <= 180 {
          points.append(.init(latitude: position.latitude, longitude: position.longitude))
        } else if abs(Int(position.longitude)) <= 180 {

          // points with incorrect longitide just rounded instead of throwing them away
          points.append(.init(latitude: position.latitude, longitude: Double(Int(position.longitude))))
        } else {
          assertionFailure("Another bad point!")
        }
      }
    }

    return .init(coordinates: points, count: points.count)
  }

  private func calculateDistance(from multiPolygoneCoordinates: MultiPolygonGeometry.Coordinates) -> Double  {
    multiPolygoneCoordinates.reduce(into: 0.0) { result, polygonCoordinates in
      result += calculateDistance(from: polygonCoordinates)
    }
  }

  private func calculateDistance(from coordinates: PolygonGeometry.Coordinates) -> Double {
    var result: Double = 0
    var points: [MKMapPoint] = []

    coordinates.forEach { positionArray in
      positionArray.forEach { position in
        points.append(.init(.init(latitude: position.latitude, longitude: position.latitude)))
      }
    }

    (1..<points.count).forEach { index in
      result += points[index].distance(to: points[index - 1])
    }

    result += points[0].distance(to: points[points.count - 1]) // shape closing

    return result
  }

  private func resolveCenter(from multiPolygoneCoordinates: MultiPolygonGeometry.Coordinates) -> MKMapPoint {
    var points: [MKMapPoint] = []

    multiPolygoneCoordinates.forEach { poligonCoordinates in
      poligonCoordinates.forEach { positions in
        positions.forEach { position in
          points.append(.init(.init(latitude: position.latitude, longitude: position.latitude)))
        }
      }
    }

    let centerX = points.reduce(into: 0.0) { result, point in
      result += point.x
    } / Double(points.count)

    let centerY = points.reduce(into: 0.0) { result, point in
      result += point.y
    } / Double(points.count)

    return .init(x: centerX, y: centerY)
  }
  
}

