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

open class TabbarCoordinator<PAGE>: TabbarCoordinatable, UITabBarControllerDelegate where PAGE: TabbarPage {
  
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  private (set) var pages: [PAGE]
  open var tabController: UITabBarController!
  open var currentPage: PAGE? {
    willSet { setCurrentPage(newValue) }
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  
  
  public init(
    tarbbarCtrl: UITabBarController = .init(),
    pages: [PAGE],
    currentPage: PAGE? = nil,
    presentationStyle: PresentationStyle = .fullScreen,
    parent: Coordinator? = nil
  ) {
    self.pages = pages
    super.init(parent: parent, presentationStyle: presentationStyle)
    tabController = tarbbarCtrl
    setup()
    defer { self.currentPage = currentPage ?? pages.first }
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  open func getCoordinatorSelected() -> Coordinator {
    children[tabController.selectedIndex]
  }
  
  public override func start(animated: Bool = true) {
    presentCoordinator(animated: animated)
  }
  
  open func buildTabbarItem(page: PAGE) -> UITabBarItem? {
    let item = UITabBarItem(
      title: page.title,
      image: page.getImage(),
      selectedImage: page.getImage()
    )
    item.tag = page.position
    return item
  }
  
  open func setPages(_ values: [PAGE], completion: (() -> Void)? = nil) {
    pages = values
    handleUpdatePages(completion: completion)
  }
  
  open func setupPages() {
    pages.forEach({
      var item = $0.coordinator()
      item.parent = self
      item.root.tabBarItem = buildTabbarItem(page: $0)
      item.start(animated: false)
    })
  }
  
  open func forcePresentation(
    animated: Bool = true,
    mainCoordinator: Coordinator? = mainCoordinator
  ) {
    let topCoordinator = getTopCoordinator(mainCoordinator: mainCoordinator)
    self.parent = topCoordinator
    start(animated: animated)
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Private helper funcs
  // ---------------------------------------------------------------------
  
  
  private func setCurrentPage(_ value: (any TabbarPage)?) {
    guard let value, value.position != currentPage?.position else { return  }
    guard let index = children.firstIndex(where: { $0.root.tabBarItem.tag == value.position })
    else {
      currentPage = nil
      return
    }
    tabController?.selectedIndex = index
  }
  
  private func handleUpdatePages(completion: (() -> Void)? = nil) {
    removeChildren(animated: false) { [weak self] in
      self?.emptyControllers()
      self?.setupPages()
      completion?()
    }
  }
  
  private func setup() {
    self.tabController?.delegate = self
    setupPages()
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: UITabBarControllerDelegate
  // ---------------------------------------------------------------------
  

  open func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    let page = pages.first(where: { $0.position == tabBarController.selectedIndex })
    guard page?.position != currentPage?.position else { return }
    currentPage = page
  }
}
