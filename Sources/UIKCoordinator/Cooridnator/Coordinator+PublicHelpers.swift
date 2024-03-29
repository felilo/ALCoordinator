//
//  Coordinator+PublicHelpers.swift
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

public extension Coordinator {
  /// navigation controller del coordinator
  var root:UINavigationController {
    return navigationController
  }
  
  
  /// Get the top coordinator
  /// - Parameters:
  ///   - appCoordinator: Main coordinator
  ///   - pCoodinator:
  func topCoordinator(pCoodinator: Coordinator? = nil) -> Coordinator? {
    guard children.last != nil else { return self }
    var auxCoordinator = pCoodinator ?? self.children.last
    return getDeepCoordinator(from: &auxCoordinator)
  }
  
  
  //
  func presentCoordinator(animated: Bool)  {
    guard var parent = self.parent else { return }
    parent.startChildCoordinator(self, animated: animated)
  }
  
  
  mutating func startChildCoordinator(_ coordinator: Coordinator, animated: Bool = true){
    children.append(coordinator)
    if let tabbar = getTabbarCoordinable(self)?.tabController {
      var ctrls = tabbar.viewControllers ?? []
      ctrls.append(coordinator.root)
      tabbar.setViewControllers(ctrls, animated: animated)
    } else if let tabbar = getTabbarCoordinable(coordinator)?.tabController {
      coordinator.root.viewControllers = [tabbar]
      present(coordinator.root, animated: animated)
    } else {
      present(coordinator.root, animated: animated)
    }
  }
  
  
  /// Close the current navigation controller and then removes it from its coordinator parent
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  func handleFinish(animated: Bool = true, withDissmis: Bool = true, completion: (() -> Void)?) {
    guard withDissmis else {
      return emptyCoordinator(completion: completion)
    }
    close(animated: animated, finishFlow: true) { emptyCoordinator(completion: completion) }
  }
  
  
  /// Close the current navigation controller and then removes it from its coordinator parent
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  func finish(
    animated: Bool = true,
    withDissmis: Bool = true,
    completion: (() -> Void)?
  ) {
    
    let handleFinish: (Coordinator?) -> Void = { coordinator in
      coordinator?.handleFinish(animated: animated, withDissmis: withDissmis, completion: completion)
    }
    
    if (self is (any TabbarCoordinatable)) {
      parent?.close(animated: animated, finishFlow: true ) { handleFinish(self) }
    } else if (parent is (any TabbarCoordinatable)) {
      close(animated: animated, finishFlow: true) { handleFinish(parent) }
    } else {
      handleFinish(self)
    }
  }
}
