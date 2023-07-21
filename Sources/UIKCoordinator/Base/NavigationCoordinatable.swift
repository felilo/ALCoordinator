//
//  File.swift
//  
//
//  Created by Andres Lozano on 14/07/23.
//

import SwiftUI

open class NavigationCoordinatable<Route: NavigationRoute>: BaseCoordinator where Route.T == UIViewController {
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  public var router: Router<Route> { .init(coordinator: self) }
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  
  
  public init(presentationStyle: UIModalPresentationStyle = .fullScreen, parent: Coordinator? = nil) {
    super.init(parent: parent, presentationStyle: presentationStyle)
  }
}
