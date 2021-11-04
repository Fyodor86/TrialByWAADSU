//
//  GeoDataFetcher.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation

protocol GeoDataFetcher {
  func fetchGeoData(fromURL: URL) async throws -> Data
}

// Fetches JSON from the Server
final class GeoDataFetcherImp: GeoDataFetcher {
  func fetchGeoData(fromURL url: URL) async throws -> Data {
    let (data, response) = try await URLSession.shared.data(for: .init(url: url))

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw AppError.fetchError
    }

    return data
  }
}

