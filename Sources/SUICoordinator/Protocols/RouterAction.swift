//
//  RouterAction.swift
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

import Foundation

public protocol RouterAction {
  
  associatedtype Route
  associatedtype ViewType
  
  func navigate(to route: Route, transitionStyle: NavigationTransitionStyle?, animated: Bool, completion: (() -> Void)?)
  func startFlow(route: Route, transitionStyle: NavigationTransitionStyle?, animated: Bool)
  func present(_ viewController: ViewType, animated: Bool, completion: (() -> Void)?)
  func pop(animated: Bool)
  func popToRoot(animated: Bool)
  func popToView<T>(_ view: T, animated: Bool) -> Bool
  func finishFlow(animated: Bool, withDissmis: Bool, completion: (() -> Void)?)
  func navigate(to coordinator: Coordinator, animated: Bool)
  func dismiss(animated: Bool, completion: (() -> Void)?)
}
