//
//  CoordinatorSUITests.swift
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

import XCTest
import SwiftUI
@testable import SUICoordinator


final class CoordinatorSUITests: XCTestCase {
  
  func test_showVew() {
    let sut = makeSut()
    sut.router.show(.firstStep)
    XCTAssertFalse(sut.root.viewControllers.isEmpty)
  }
  
  func test_navigatingToHostingViewControllerViaSUIView() {
    typealias Item = UIHostingController<FirstView>
    let sut = makeSut()
    let item = Item(rootView: FirstView())
    
    navigateToViewExpect(sut.router, toCompleteWithView: item, when: {
      sut.router.push(item, animated: false)
      sut.router.push(.init(), animated: false)
      sut.router.popToView(Item.self, animated: false)
    })
  }
}


extension CoordinatorSUITests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func makeSut() -> NavigationCoordinatable<MyRouter> {
    let coordinator = NavigationCoordinatable<MyRouter>.init(
      parent: MainCoordinator(parent: nil)
    )
    return coordinator
  }
  
  
  private class ChildCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.push(.init(), animated: animated)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private func navigateToViewExpect(
    _ sut: Router<MyRouter>,
    toCompleteWithView expectedView: UIViewController?,
    when action: @escaping () -> Void
  ) {
    sut.push(.init(), animated: false)
    action()
    let lastCtrl = sut.stackViews.last
    XCTAssertEqual(lastCtrl, expectedView)
  }
}


extension CoordinatorSUITests {
  
  private enum MyRouter: NavigationRoute {
    
    case firstStep
    case secondStep
    
    func view() -> any View {
      CustomView()
    }
    
    var transition: NavigationTransitionStyle {
      switch self {
        case .firstStep: return .push
        case .secondStep: return .present
      }
    }
  }
  
  struct FirstView: View {
    var body: some View { Text("FirstView") }
  }
  
  private struct CustomView: View {
    var body: some View { Text("") }
  }
  
  private class MainCoordinator: BaseCoordinator { }
}
