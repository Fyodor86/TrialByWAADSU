//
//  Spinner.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import SwiftUI

struct Spinner: UIViewRepresentable {
  func makeUIView(context: UIViewRepresentableContext<Spinner>) -> UIActivityIndicatorView {
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.color = .black
    spinner.backgroundColor = .clear
    spinner.startAnimating()
    return spinner
  }
  
  func updateUIView(_ indicator: UIActivityIndicatorView, context: UIViewRepresentableContext<Spinner>) { }
}
