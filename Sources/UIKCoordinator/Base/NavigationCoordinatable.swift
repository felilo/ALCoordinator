//
//  File.swift
//  
//
//  Created by Andres Lozano on 14/07/23.
//

import SwiftUI

open class NavigationCoordinatable<Route: NavigationRoute>: BaseCoordinator where Route.T == UIViewController {
  
  public var router: Router<Route> {
    .init(coordinator: self)
  }
}
