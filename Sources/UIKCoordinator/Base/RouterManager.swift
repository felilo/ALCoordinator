//
//  RouterManager.swift
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


open class RouterManager  {
  
  
  private (set) var coordinator: Coordinator
  
  
  public init(coordinator: Coordinator) {
    self.coordinator = coordinator
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  public func show(
    _ view: UIViewController,
    transitionStyle: NavigationTransitionStyle,
    animated: Bool = true
  ) {
    handlePresentCtrl(
      view,
      transitionStyle: transitionStyle,
      coordinator: coordinator,
      animated: animated
    )
  }
  
  
  /// Present ViewController
  /// - Parameters:
  ///   - viewController: controlador que llega como parametro
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  public func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
    coordinator.present(viewController, animated: animated, completion: completion)
  }
  
  
  /// Close the ViewController doing a pop
  /// - Parameter animated: define si se quiere mostrar la animación
  public func pop(animated: Bool = true) {
    coordinator.pop(animated: animated)
  }
  
  
  /// Close the ViewController doing a popToRoot
  /// - Parameter animated: Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  public func popToRoot(animated: Bool = true) {
    coordinator.popToRoot(animated: animated)
  }
  
  
  @discardableResult
  public func popToView<T>(_ view: T, animated: Bool = true) -> Bool {
    coordinator.popToView(view, animated: animated)
  }
  
  
  /// Close the ViewController doing a dismiss
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion: se requiere hacer un proceso previo antes de finalizar la desvinculacion
  public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    coordinator.dismiss(animated: animated, completion: completion)
  }
  
  
  /// Close the current navigation controller and then removes it from its coordinator parent
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  public func finish(animated: Bool = true, withDissmis: Bool = true, completion: (() -> Void)?) {
    coordinator.finish(animated: animated, withDissmis: withDissmis, completion: completion)
  }
  
  public var stackViews: [UIViewController] {
    coordinator.root.viewControllers
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Private funcs
  // ---------------------------------------------------------------------
  
  
  private func handlePresentCtrl(ctrl: UIViewController, style: UIModalPresentationStyle, coordinator: Coordinator, animated: Bool) {
    handlePresentation(coordinator: coordinator, ctrl: ctrl) { [weak self] in
      ctrl.modalPresentationStyle = style
      self?.present(ctrl, animated: animated)
    }
  }
  
  
  private func handlePushCtrl(ctrl: UIViewController, coordinator: Coordinator, animated: Bool) {
    handlePresentation(coordinator: coordinator, ctrl: ctrl) { [weak self] in
      self?.coordinator.push(ctrl, animated: animated)
    }
  }
  
  
  private func handlePresentation(coordinator: Coordinator, ctrl: UIViewController, _ presentation: @escaping () -> ()) {
    if coordinator.root.viewControllers.isEmpty {
      coordinator.root.viewControllers = [ctrl]
    } else {
      presentation()
    }
  }
  
  
  private func handlePresentCtrl(
    _ ctrl: UIViewController,
    transitionStyle: NavigationTransitionStyle,
    coordinator: Coordinator,
    animated: Bool
  ) {
    
    let handlePresent: (UIModalPresentationStyle) -> Void = { [weak self] style in
      self?.handlePresentCtrl(ctrl: ctrl, style: style, coordinator: coordinator, animated: animated)
    }
    
    switch transitionStyle {
      case .present:
        handlePresent(.automatic)
      case .presentFullscreen:
        handlePresent(.fullScreen)
      case .push:
        handlePushCtrl(ctrl: ctrl, coordinator: coordinator, animated: animated)
      case .custom(let style):
        handlePresent(style)
    }
  }
}

