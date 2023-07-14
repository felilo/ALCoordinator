//
//  ManagerCoordinatorSUI.swift
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


import SwiftUI

public class RouterSUIManager<Route: NavigationRoute>: RouterManager where Route.T == (any View) {
  
  
  override init(coordinator: Coordinator) {
    super.init(coordinator: coordinator)
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  open func show(
    _ route: Route,
    transitionStyle: NavigationTransitionStyle? = nil,
    animated: Bool = true
  ) {
    let ctrl = buildHostingCtrl(view: route.view())
    
    handlePresentCtrl(
      ctrl,
      transitionStyle: transitionStyle ?? route.transition,
      coordinator: coordinator,
      animated: animated
    )
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  private func buildHostingCtrl(view: (any View)) -> UIViewController {
    let ctrl = UIHostingController(rootView: AnyView(view))
    return ctrl
  }
}



public protocol RouterActions {
  
  associatedtype Route
  
  func show(_ coordinator: Coordinator, route: Route, transitionStyle: NavigationTransitionStyle?, animated: Bool) -> Void
  func getTopCoordinator(mainCoordinator: Coordinator?) -> Coordinator?
  func restartMainCoordinator(mainCoordinator: Coordinator?, animated: Bool, completion: (() -> Void)?) -> Void
  
  
}
