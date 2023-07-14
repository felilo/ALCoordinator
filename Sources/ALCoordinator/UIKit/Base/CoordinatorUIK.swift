//
//  File.swift
//  
//
//  Created by Andres Lozano on 14/07/23.
//

import SwiftUI

open class CoordinatorUIK<Route: NavigationRoute>: BaseCoordinator where Route.T == UIViewController {
  
  
  public var router: RouterUIKManager<Route> {
    .init(coordinator: self)
  }
}
