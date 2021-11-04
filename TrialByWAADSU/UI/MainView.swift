//
//  ContentView.swift
//  TrialByWAADSU
//
//  Created by Fedor Baryshnikov on 04.11.2021.
//

import SwiftUI

struct MainView<VM>: View where VM: ViewModel {
  @ObservedObject private var viewModel: VM
  
  init(viewModel: VM) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    MapView(route: $viewModel.route)
      .ignoresSafeArea()
      .overlay(alignment: .bottom) {
        button
          .padding(.horizontal)
          .opacity(viewModel.state == .loaded ? 0 : 1)
      }
      .overlay(alignment: .bottom) {
        distanceMessage
      }
      .animation(.default, value: viewModel.state)
      .alert(item: $viewModel.errorMessage) { message in
        Alert(
          title: Text("Error"),
          message: Text(message),
          dismissButton: .default(Text("Reset"), action: viewModel.reset))
        
      }
  }
}

private extension MainView {
  var map: some View {
    MapView(route: $viewModel.route)
  }
  
  @ViewBuilder
  var button: some View {
    Group {
      switch viewModel.state {
      case .initial:
        loadButton
      case .loading:
        spinner
      case .loaded, .error:
        clearButton
      }
    }
    .foregroundColor(.black)
    .padding()
    .background(Color.orange)
    .clipShape(Capsule())
  }
  
  var loadButton: some View {
    Button {
      Task.init(priority: .high) {
        await
        viewModel.getRoute()
      }
    } label: {
      Text("Get route")
    }
  }
  
  var clearButton: some View {
    Button {
      viewModel.reset()
    } label: {
      Text("Reset")
    }
  }
  
  var spinner: some View {
    Button {
    } label: {
      HStack {
        Text("Loading")
        Spinner()
      }
    }
  }
  
  @ViewBuilder
  var distanceMessage: some View {
    if viewModel.state == .loaded {
      HStack {
        Text("The route length is \(viewModel.route?.distanceInKilometersRounded ?? 0) km")
          .multilineTextAlignment(.center)
        Spacer()
        button
      }
      .padding()
      .background(.ultraThinMaterial)
      .transition(.move(edge: .bottom))
    }
  }
  
}

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(viewModel: Factory.createViewModel())
  }
}

extension String: Identifiable {
  public var id: String {
    self
  }
}
