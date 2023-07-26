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

  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------

  
  private  var coordinator: Coordinator
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  

  public init(coordinator: Coordinator) {
    self.coordinator = coordinator
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  public func navigate<T>(
    _ view: T,
    transitionStyle: NavigationTransitionStyle,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) where T: UIViewController {
    handlePresentCtrl(
      view,
      transitionStyle: transitionStyle,
      coordinator: coordinator,
      animated: animated,
      completion: completion
    )
  }
  
  
  /// Present ViewController
  /// - Parameters:
  ///   - viewController: controlador que llega como parametro
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  open func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
    coordinator.present(viewController, animated: animated, completion: completion)
  }
  
  
  /// Close the ViewController doing a pop
  /// - Parameter animated: define si se quiere mostrar la animación
  open func pop(animated: Bool = true) {
    coordinator.pop(animated: animated)
  }
  
  
  /// Close the ViewController doing a popToRoot
  /// - Parameter animated: Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  open func popToRoot(animated: Bool = true) {
    coordinator.popToRoot(animated: animated)
  }
  
  
  @discardableResult
  open func popToView<T>(_ view: T, animated: Bool = true) -> Bool {
    coordinator.popToView(view, animated: animated)
  }
  
  
  /// Close the ViewController doing a dismiss
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion: se requiere hacer un proceso previo antes de finalizar la desvinculacion
  open func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
    coordinator.dismiss(animated: animated, finishFlow: false, completion: completion)
  }
  
  
  /// Close the current navigation controller and then removes it from its coordinator parent
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  open func finishFlow(animated: Bool = true, withDissmis: Bool = true, completion: (() -> Void)?) {
    coordinator.finish(animated: animated, withDissmis: withDissmis, completion: completion)
  }
  
  
  /// Open current navigation controller and then removes it from its coordinator parent
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  open func navigate(to coordinator: Coordinator, animated: Bool = true) {
    var aux: Coordinator = coordinator
    aux.parent = self.coordinator
    aux.start(animated: animated)
  }
  
  
  /// Open current navigation controller and then removes it from its coordinator parent
  /// - Parameters:
  ///   - animated: Bool, Specify true to animate the transition or false if you do not want the transition to be animated. You might specify false if you are setting up the navigation controller at launch time.
  ///   - completion
  open func startFlow(_ view: UIViewController, transitionStyle: NavigationTransitionStyle, animated: Bool = true) {
    navigate(view, transitionStyle: transitionStyle, animated: animated)
    coordinator.presentCoordinator(animated: animated)
  }
  
  
  open var stackViews: [UIViewController] {
    coordinator.root.viewControllers
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Private funcs
  // ---------------------------------------------------------------------
  
  
  private func handlePresentCtrl(
    ctrl: UIViewController,
    style: PresentationStyle,
    coordinator: Coordinator,
    animated: Bool,
    completion: (() -> Void)? = nil
  ) {
    handlePresentation(coordinator: coordinator, ctrl: ctrl) { [weak self] in
      ctrl.modalPresentationStyle = style
      self?.present(ctrl, animated: animated, completion: completion)
    }
  }
  
  
  private func handlePushCtrl(ctrl: UIViewController, coordinator: Coordinator, animated: Bool, completion: (() -> Void)? = nil) {
    handlePresentation(coordinator: coordinator, ctrl: ctrl) { [weak self] in
      self?.coordinator.push(ctrl, animated: animated, completion: completion)
    }
  }
  
  
  private func handlePresentation(coordinator: Coordinator, ctrl: UIViewController, _ presentation: @escaping () -> ()) {
    if stackViews.isEmpty {
      coordinator.root.viewControllers = [ctrl]
    } else {
      presentation()
    }
  }
  
  
  private func handlePresentCtrl(
    _ ctrl: UIViewController,
    transitionStyle: NavigationTransitionStyle,
    coordinator: Coordinator,
    animated: Bool,
    completion: (() -> Void)? = nil
  ) {
    
    let handlePresent: (PresentationStyle) -> Void = { [weak self] style in
      self?.handlePresentCtrl(
        ctrl: ctrl,
        style: style,
        coordinator: coordinator,
        animated: animated,
        completion: completion
      )
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

