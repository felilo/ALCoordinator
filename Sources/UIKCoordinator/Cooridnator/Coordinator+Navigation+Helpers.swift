//
//  Coordinator+Navigation+Helpers.swift
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
  
  
  // ---------------------------------------------------------
  // MARK: Helpers func
  // ---------------------------------------------------------
  
  
  /// Push ViewController
  /// - Parameters:
  ///   - viewController: The view controller to push onto the stack. This object cannot be a tab bar controller. If the view controller is already on the navigation stack, this method throws an exception.
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  func push(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
    root.pushViewController(viewController, animated: animated)
    completion?()
  }
  
  
  /// Present ViewController
  /// - Parameters:
  ///   - viewController: controlador que llega como parametro
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
      root.present(viewController, animated: animated, completion: completion)
    }
  }
  
  
  /// Close the ViewController doing a pop
  /// - Parameter animated: define si se quiere mostrar la animación
  func pop(animated: Bool = true) {
    root.popViewController(animated: animated)
  }
  
  
  /// Close the ViewController doing a popToRoot
  /// - Parameter animated: Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  func popToRoot(animated: Bool = true) {
    root.popToRootViewController(animated: animated)
  }
  
  
  @discardableResult
  func popToView<T>(_ view: T, animated: Bool = true) -> Bool {
    isPopToViewController(
      name: getNameOf(object: view),
      animated: animated
    )
  }
  
  
  /// Close the ViewController doing a dismiss
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion: se requiere hacer un proceso previo antes de finalizar la desvinculacion
  func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    root.dismiss(animated: animated, completion: completion)
  }
  
  
  /// Close the ViewController, this function checks what kind of presentation has the controller and then it make a dismiss or pop
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion: se requiere hacer un proceso previo antes de finalizar la desvinculacion
  func close(animated: Bool = true, completion: (() -> Void)? = nil) {
    let isDismiss = root.isModal || (root.viewControllers.last?.isModal == true)
    if isDismiss || parent == nil {
      dismiss(animated: animated, completion: completion)
    } else {
      pop(animated: animated)
      completion?()
    }
  }
  
  
  // Restart coordinator
  func restart(animated: Bool, completion: (() -> Void)?) {
    finish(animated: animated) {
      start(animated: animated)
      completion?()
    }
  }
}
