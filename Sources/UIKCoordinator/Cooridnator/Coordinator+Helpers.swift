//
//  Coordinator+Helpers.swift
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

extension Coordinator {
  
  @discardableResult
  func isPopToViewController(name: String, animated: Bool = true) -> Bool {
    let ctrl = root.viewControllers.first { vc in
      vc.name == name || vc.name == "UIHostingController<\(name)>"
    }
    if let ctrl {
      root.popToViewController(ctrl, animated: animated)
    }
    return ctrl != nil
  }
  
  
  /// Get name of an objetc
  /// - Parameters:
  ///   - viewController: UIViewController
  func getNameOf(viewController: UIViewController) -> String {
    "\(type(of: viewController))"
  }
  
  
  /// Get name of an objetc
  /// - Parameters:
  ///   - object: Any
  func getNameOf<T>(object: T) -> String {
    String(describing: object.self)
  }
  
  
  /// Get the deepest coordinator from a given coordinator as parameter
  /// - Parameters:
  ///   - value: Coordinator
  func getDeepCoordinator(from value: inout Coordinator?) -> Coordinator?{
    if value?.children.last == nil {
      return value
    } else if let value = value, let tabCoordinator = getTabbarCoordinable(value) {
      return topCoordinator(pCoodinator: tabCoordinator.getCoordinatorSelected())
    } else {
      var last = value?.children.last
      return getDeepCoordinator(from: &last)
    }
  }
  
  
  /// Remove its coordinator child
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - coordinator: Coordinator
  ///   - completion
  func removeChild(coordinator : Coordinator, completion:(() -> Void)? = nil) {
    guard let index = children.firstIndex(where: {$0.uuid == coordinator.uuid}) else {
      completion?()
      return
    }
    var aux = self
    aux.children.remove(at: index)
    coordinator.removeChildren {
      removeChild(coordinator: coordinator, completion: completion)
    }
  }
  
  
  /// Remove its coordinators children
  /// - Parameter animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  func removeChildren(animated: Bool = false, _ completion:(() -> Void)? = nil){
    
    guard let coordinator = children.first else {
      completion?()
      return
    }
    coordinator.handleFinish(animated: animated, withDissmis: false, completion: {
      removeChildren(completion)
    })
  }
  
  
  // Clear all its properties
  func emptyControllers() {
    if let item = getTabbarCoordinable(self) {
      item.tabController?.viewControllers = []
    }
    root.viewControllers = []
  }
  
  
  func emptyCoordinator(completion: (() -> Void)?) {
    guard let parent = parent else {
      popToRoot(animated: false)
      return removeChildren(completion)
    }
    emptyControllers()
    parent.removeChild(
      coordinator: self,
      completion: completion
    )
  }
  
  
  func getTabbarCoordinable(_ coordinator: Coordinator) ->  (any TabbarCoordinatable)? {
    coordinator as? (any TabbarCoordinatable)
  }
  
  
  func getLatestViewCtrl(_ ctrl: UIViewController? = nil) -> UIViewController? {
    if ctrl?.presentedViewController == nil {
      if let navCtrl = ctrl as? UINavigationController {
        return navCtrl.viewControllers.last
      }
      return ctrl
    } else if let navCtrl = ctrl as? UINavigationController {
      return getLatestViewCtrl(navCtrl.viewControllers.last)
    } else {
      return getLatestViewCtrl(ctrl?.presentedViewController)
    }
  }
}
