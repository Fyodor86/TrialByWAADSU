//
//  ErrorHandler.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation

protocol ErrorHandler {
  func generateMessage(forError: AppError) -> String
}


class ErrorHandlerImp: ErrorHandler {
  func generateMessage(forError error: AppError) -> String {
    let message: String
    switch error {
    case .urlError:
      message = "Invalid URL"
    case .fetchError:
      message = "Some server problems"
    case .parseError:
      message = "Bad data"
    case .unknown:
      message = "Unknown error"
    }
    return message
  }
}
