//
//  CustomTabbarCtrl.swift
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
import SwiftUI

public class CustomTabbarCtrl: UITabBarController {
  
  
  // ---------------------------------------------------------------------
  // MARK: Variables
  // ---------------------------------------------------------------------
  
  
  private var customView: (any View)
  private var customContainerView: UIView?
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  
  
  public init(view: some View) {
    self.customView = view
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Life cycle
  // ---------------------------------------------------------------------
  
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    hideTabBarBorder()
    setupCustomView()
    viewControllers = []
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    customContainerView?.frame = tabBar.frame
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  private func setupCustomView() {
    let ctrl = buildHostingCtrl(view: customView)
    guard let customView = ctrl.view else { return }
    customContainerView = customView
    customContainerView?.backgroundColor = .clear
    addChild(ctrl)
    self.view.addSubview(customView)
    self.view.bringSubviewToFront(self.tabBar)
  }
  
  
  private func buildHostingCtrl(view: any View) -> UIViewController {
    return UIHostingController(rootView: AnyView(view))
  }
  
  private func hideTabBarBorder() {
    let tabBar = self.tabBar
    tabBar.backgroundImage = from(color: .clear)
    tabBar.shadowImage = UIImage()
    tabBar.clipsToBounds = true
  }
  
  private func from(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }
}


