//
//  Factory.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation

class Factory {
  static func createViewModel() -> some ViewModel {
    ViewModelImp(
      urlString: "https://waadsu.com/api/russia.geo.json",
      fetcher: GeoDataFetcherImp(),
      parser: GeoDataParserImp(),
      errorHandler: ErrorHandlerImp())
  }
}


