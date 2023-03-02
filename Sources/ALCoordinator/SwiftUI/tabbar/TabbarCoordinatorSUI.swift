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
import ALCoordinator

open class TabbarCoordinatorSUI<Router: TabbarNavigationRouter>: TabbarCoordinator {
  
  
  public var cancelables = Set<AnyCancellable>()
  private (set) var tabbarViewStyle: TabbarViewStyle = .default
  public typealias Router = Router
  
  
  // ---------------------------------------------------------------------
  // MARK: Helper funcs
  // ---------------------------------------------------------------------
  
  
  public override func start(animated: Bool = true) {
    parent.children += [self]
    tabController.modalPresentationStyle = .fullScreen
    parent.present(tabController, animated: animated)
  }
  
  
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
  
  
  public enum TabbarViewStyle: Equatable {
    static public func == (lhs: TabbarCoordinatorSUI<Router>.TabbarViewStyle, rhs: TabbarCoordinatorSUI<Router>.TabbarViewStyle) -> Bool {
      lhs.id == rhs.id
    }
    
    case `default`
    case custom(value: any View)
    
    
    private var id: Int {
      switch self {
        case .default: return 0
        case .custom: return 1
      }
    }
  }
}


