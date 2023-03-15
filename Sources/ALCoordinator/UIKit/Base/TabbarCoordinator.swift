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
import SwiftUI

open class TabbarCoordinator<PAGE>: TabbarCoordinatable where PAGE: TabbarPage {
  
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  open var tabController: UITabBarController!
  
  open var currentPage: PAGE? {
    didSet { setCurrentPage(currentPage) }
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------

  
  public init(parent: Coordinator?, tarbbarCtrl: UITabBarController = .init(), pages: [PAGE]) {
    super.init(parent: parent)
    tabController = tarbbarCtrl
    setupPages(pages)
  }
  
  
  public init(parent: Coordinator?, customView: any View, pages: [PAGE]) {
    super.init(parent: parent)
    tabController = CustomTabbarCtrl(view: customView)
    setupPages(pages)
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  open func getCoordinatorSelected() -> Coordinator {
    children[tabController.selectedIndex]
  }
  
  
  public override func start(animated: Bool = true) {
    parent.children.append(self)
    tabController.modalPresentationStyle = .fullScreen
    parent.present(tabController, animated: animated)
  }
  
  
  open func buildTabbarItem(page: PAGE) -> UITabBarItem? {
    let item = UITabBarItem(
      title: page.title,
      image: .init(systemName: page.icon),
      selectedImage: .init(systemName: page.icon)
    )
    item.tag = page.position
    return item
  }
  
  
  open func setupPages(_ values: [PAGE]) {
    values.forEach({
      let item = $0.coordinator(parent: self)
      item.root.tabBarItem = buildTabbarItem(page: $0)
      item.start(animated: false)
    })
    currentPage = values.first
  }
  
  
  open func setPages(_ values: [PAGE]) {
    removeChildren(animated: false) { [weak self] in
      self?.setupPages(values)
    }
  }
  
  
  private func setCurrentPage(_ value: TabbarPage?) {
    guard let value,
          let index = children.firstIndex(where: { $0.root.tabBarItem.tag == value.position })
    else {
      currentPage = nil
      return
    }
    tabController.selectedIndex = index
  }
}
