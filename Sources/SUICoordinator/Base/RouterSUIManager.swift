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
import UIKCoordinator

public class RouterSUIManager<Route: NavigationRoute>: RouterManager where Route.T == (any View) {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  public func show(
    _ route: Route,
    transitionStyle: NavigationTransitionStyle? = nil,
    animated: Bool = true
  ) {
    super.show(
      buildHostingCtrl(view: route.view()),
      transitionStyle: transitionStyle ?? route.transition
    )
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Private funcs
  // ---------------------------------------------------------------------
  
  
  private func buildHostingCtrl(view: (any View)) -> UIViewController {
    return UIHostingController(rootView: AnyView(view))
  }
}

