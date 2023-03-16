//
//  UIViewController+Helpers.swift
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

private var tagAssociationKey: UInt8 = 0
private var nameAssociationKey: UInt8 = 0

public extension UIViewController {
  
  var isModal: Bool {
    if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
      return false
    } else if presentingViewController != nil {
      return true
    } else if let navigationController = navigationController, navigationController.presentingViewController?.presentedViewController == navigationController {
      return true
    } else if let tabBarController = tabBarController, tabBarController.presentingViewController is UITabBarController {
      return true
    } else {
      return false
    }
  }
  
  
  var name: String {
    get { getAssociatedObject(key: &nameAssociationKey) ?? "\(type(of: self))" }
  }
  
  
  private func getAssociatedObject(key: inout UInt8) -> String? {
    objc_getAssociatedObject(self, &key) as? String
  }
}
