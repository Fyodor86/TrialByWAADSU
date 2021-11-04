//
//  AppError.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import Foundation

enum AppError: String, Error {
  case urlError
  case fetchError
  case parseError
  case unknown
}
