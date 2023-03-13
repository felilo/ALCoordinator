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

open class TabbarCoordinatorSUI<Router: TabbarPage>: TabbarCoordinator {
  
  
  public typealias Router = Router
  
  
  // ---------------------------------------------------------------------
  // MARK: Properties
  // ---------------------------------------------------------------------
  
  
  public var cancelables = Set<AnyCancellable>()

  
  // ---------------------------------------------------------------------
  // MARK: Constructor
  // ---------------------------------------------------------------------
  

  public init(
    withParent parent: Coordinator,
    pages: [TabbarPage],
    customView: TabbarViewStyle = .default
  ) {
    switch customView {
      case .custom(let view):
        super.init(
          parent: parent,
          tarbbarCtrl: CustomTabbarCtrl(view: view),
          pages: pages
        )
      default:
        super.init(
          parent: parent,
          pages: pages
        )
    }
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
      lhs: TabbarViewStyle,
      rhs: TabbarViewStyle
    ) -> Bool { lhs.id == rhs.id }
    
    
    private var id: Int {
      switch self {
        case .default: return 0
        case .custom: return 1
      }
    }
  }
}
