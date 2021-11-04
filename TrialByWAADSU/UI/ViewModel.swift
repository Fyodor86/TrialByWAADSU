//
//  ViewModel.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation

protocol ViewModel: ObservableObject {
  var state: AppState { get }
  var route: Route? { get set }
  var errorMessage: String? { get set }

  func getRoute() async
  func reset()
}


final class ViewModelImp: ViewModel {
  @Published var state: AppState = .initial
  @Published var route: Route?
  @Published var errorMessage: String?

  private let urlString: String
  private let dataFetcher: GeoDataFetcher
  private let dataParser: GeoDataParser
  private let errorHandler: ErrorHandler



  init(
    urlString: String,
    fetcher: GeoDataFetcher,
    parser: GeoDataParser,
    errorHandler: ErrorHandler
  ) {
    self.urlString = urlString
    self.dataFetcher = fetcher
    self.dataParser = parser
    self.errorHandler = errorHandler
  }

  @MainActor
  func getRoute() async {
    switch await fetchAndParseData() {
    case .success(let route):
      self.route = route
      self.state = .loaded
    case .failure(let error):
      self.state = .error
      self.errorMessage = errorHandler.generateMessage(forError: error)
    }
  }

  func fetchAndParseData() async -> Result<Route, AppError> {
    state = .loading

    guard let url = URL(string: urlString) else {
      return .failure(.urlError)
    }

    guard let data = try? await dataFetcher.fetchGeoData(fromURL: url) else {
      return .failure(.fetchError)
    }

    guard let route = try? await dataParser.parse(data: data) else {
      return .failure(.parseError)
    }

    return .success(route)
  }

  func reset() {
    self.state = .initial
    self.route = nil
    self.errorMessage = nil
  }

}

