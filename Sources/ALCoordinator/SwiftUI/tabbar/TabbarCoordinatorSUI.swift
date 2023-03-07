//
//  TabbarCoordinatorSUI.swift
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



import SwiftUI
import Combine

open class TabbarCoordinatorSUI<Router: TabbarNavigationRouter>: TabbarCoordinator {
  
  
  public typealias Router = Router
  
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  public var cancelables = Set<AnyCancellable>()
  private (set) var tabbarViewStyle: TabbarViewStyle = .default

  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  

  public init(
    withParent parent: Coordinator,
    pages: [TapPageSUI],
    customView: TabbarViewStyle = .default
  ) {
    super.init(withParent: parent)
    setupTabbarView(customView)
    setupPages(pages)
  }
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  public override func start(animated: Bool = true) {
    parent.children += [self]
    tabController.modalPresentationStyle = .fullScreen
    parent.present(tabController, animated: animated)
  }

  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  

  open func setupTabbarView(_ value: TabbarViewStyle = .default) {
    tabbarViewStyle = value
    switch value {
      case .custom(let view):
        tabController = CustomTabbarCtrl(view: view)
      default:
        tabController = .init()
    }
  }
  
  
  open func buildTabbarItem(page: TabbarPage) -> UITabBarItem? {
    guard tabbarViewStyle == .default else { return nil }
    return .init(
      title: page.title,
      image: .init(systemName: page.icon),
      selectedImage: .init(systemName: page.icon)
    )
  }
  
  
  open func setupPages(_ values: [TapPageSUI]) {
    values.forEach({
      let item = $0.coordinator(parent: self)
      item.root.tabBarItem = buildTabbarItem(page: $0)
      item.start(animated: false)
    })
  }

  
  // ---------------------------------------------------------------------
  // MARK: Enums
  // ---------------------------------------------------------------------
  

  public enum TabbarViewStyle: Equatable {
    
    
    case `default`
    case custom(value: any View)
    
    
    // ---------------------------------------------------------------------
    // MARK: Equatable
    // ---------------------------------------------------------------------
    
    
    static public func == (
      lhs: TabbarCoordinatorSUI<Router>.TabbarViewStyle,
      rhs: TabbarCoordinatorSUI<Router>.TabbarViewStyle
    ) -> Bool { lhs.id == rhs.id }
    
    
    private var id: Int {
      switch self {
        case .default: return 0
        case .custom: return 1
      }
    }
  }
}
