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
  
  
  public init(parent: Coordinator?) {
    self.parent = parent
    uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
    super.init()
  }
  
  
  public init(
    withParent parent: Coordinator,
    presentationStyle: UIModalPresentationStyle = .fullScreen
  ) {
    self.parent = parent
    uuid = "\(NSStringFromClass(type(of: self))) - \(UUID().uuidString)"
    super.init()
    root.modalPresentationStyle = presentationStyle
    root.setNavigationBarHidden(true, animated: false)
    handlePresentationStyle()
  }
  
  
  // ---------------------------------------------------------
  // MARK: Helpers func
  // ---------------------------------------------------------
  
  
  open func start(animated: Bool = true ) {
    fatalError("start(animated:) has not been implemented")
  }
  
  
  private func handlePresentationStyle() {
    switch root.modalPresentationStyle {
      case .custom,  .none, .automatic, .fullScreen:
        return
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
    finish(withDissmis: false, completion: nil)
  }
}
