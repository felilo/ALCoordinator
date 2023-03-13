//
//  TabbarCoordinator.swift
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

open class TabbarCoordinator: BaseCoordinator {
  
  
  public typealias T = UITabBarController
  
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  open var tabController: T!
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------

  
  init(parent: Coordinator?, tarbbarCtrl: UITabBarController = .init(), pages: [TabbarPage]) {
    super.init(parent: parent)
    tabController = tarbbarCtrl
    setupPages(pages)
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  public override func start(animated: Bool = true) {
    parent.children.append(self)
    tabController.modalPresentationStyle = .fullScreen
    parent.present(tabController, animated: animated)
  }
  
  
  open func buildTabbarItem(page: TabbarPage) -> UITabBarItem? {
    return .init(
      title: page.title,
      image: .init(systemName: page.icon),
      selectedImage: .init(systemName: page.icon)
    )
  }
  
  
  open func setupPages(_ values: [TabbarPage]) {
    values.forEach({
      let item = $0.coordinator(parent: self)
      item.root.tabBarItem = buildTabbarItem(page: $0)
      item.start(animated: false)
    })
  }
}
