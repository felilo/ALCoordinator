//
//  BaseCoordinator.swift
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

open class BaseCoordinator: NSObject, Coordinator  {
  
  
  // ---------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------
  
  
  public static var mainCoordinator: Coordinator?
  open var uuid: String
  open var parent: Coordinator!
  open var children = [Coordinator]()
  open var navigationController: UINavigationController = .init()
  
  
  // ---------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------
  
  
  public init(parent: Coordinator?, presentationStyle: UIModalPresentationStyle = .fullScreen) {
    uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
    self.parent = parent
    super.init()
    handlePresentationStyle(presentationStyle: presentationStyle)
  }
  
  
  // ---------------------------------------------------------
  // MARK: Helpers func
  // ---------------------------------------------------------
  
  
  open func start(animated: Bool = true ) {
    fatalError("start(animated:) has not been implemented")
  }
  
  
  open func getTopCoordinator(mainCoordinator: Coordinator? = mainCoordinator) -> Coordinator? {
    mainCoordinator?.topCoordinator()
  }
  
  
  open func restartMainCoordinator(mainCoordinator: Coordinator? = mainCoordinator, animated: Bool, completion: (() -> Void)?){
    mainCoordinator?.restart(animated: animated, completion: completion)
  }
  
  
  private func handlePresentationStyle(presentationStyle: UIModalPresentationStyle) {
    root.modalPresentationStyle = presentationStyle
    switch presentationStyle {
      case .custom, .none, .automatic, .fullScreen:
        break
      default:
        root.presentationController?.delegate = self
    }
  }
}



extension BaseCoordinator: UIAdaptivePresentationControllerDelegate {
  
  
  // ---------------------------------------------------------------------
  // MARK: UIAdaptivePresentationControllerDelegate
  // ---------------------------------------------------------------------
  
  
  public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
    finish(withDissmis: true, completion: nil)
  }
}
