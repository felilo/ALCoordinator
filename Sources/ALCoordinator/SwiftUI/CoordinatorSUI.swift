//
//  CoordinatorSUI.swift
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
import Combine

open class CoordinatorSUI<Router: NavigationRouter>: BaseCoordinator {
  
  
  private let manager = ManagerCoordinatorSUI<Router>()
  public var cancelables = Set<AnyCancellable>()
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  open func show(_ router: Router, transitionStyle: NavigationTranisitionStyle? = nil, animated: Bool = true) {
    manager.show(self, router: router, transitionStyle: transitionStyle, animated: animated)
  }
  
  
  open func restartMainCoordinator(mainCoordinator: Coordinator? = nil, animated: Bool, completion: (() -> Void)? ) {
    manager.restartMainCoordinator(
      mainCoordinator: mainCoordinator,
      animated: animated,
      completion: completion
    )
  }
}


