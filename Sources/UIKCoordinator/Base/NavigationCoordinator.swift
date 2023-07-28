//
//  File.swift
//  
//
//  Created by Andres Lozano on 14/07/23.
//

import UIKit

open class NavigationCoordinator<Route: NavigationRoute>: BaseCoordinator where Route.T == UIViewController {
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  public var router: Router<Route> { .init(coordinator: self) }
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  
  
  public init(presentationStyle: PresentationStyle = .fullScreen, parent: Coordinator? = nil) {
    super.init(parent: parent, presentationStyle: presentationStyle)
  }


  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  

  open func forcePresentation(
    route: Route,
    transitionStyle: NavigationTransitionStyle? = nil,
    animated: Bool = true,
    mainCoordinator: Coordinator? = mainCoordinator
  ) {
    let topCoordinator = getTopCoordinator(mainCoordinator: mainCoordinator)
    self.parent = topCoordinator
    router.startFlow(
      route: route,
      transitionStyle: transitionStyle ?? route.transition,
      animated: animated
    )
  }
}
