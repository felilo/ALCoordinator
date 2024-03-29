//
//  NavigationCoordinator.swift
//
//  Copyright (c) Andres F. Lozano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

open class NavigationCoordinator<Route: NavigationRoute>: BaseCoordinator, NavigationAction where Route.T == UIViewController {
  
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
    startWith route: Route,
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
