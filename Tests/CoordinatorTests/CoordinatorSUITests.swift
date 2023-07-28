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
    sut.router.navigate(to: .firstStep)
    XCTAssertFalse(sut.root.viewControllers.isEmpty)
  }
  
  func test_navigatingToHostingViewControllerViaSUIView() {
    typealias Item = FirstView
    let sut = makeSut()
    
    sut.router.navigate(to: .firstStep, animated: false)
    sut.router.navigate(to: .secondStep, animated: false)
    sut.router.popToView(Item.self, animated: false)
    
    finish(sut: sut.router) {
      let lastCtrl = sut.router.stackViews.last
      XCTAssertEqual(lastCtrl?.name, "UIHostingController<\(Item.self)>")
    }
  }
  
  func test_force_to_present_a_coordinator() {
    let sut = makeSut()
    
    XCTAssertTrue(sut.children.isEmpty)
    
    let makeChildCoordinator = NavigationCoordinator<MyRouter>()
    makeChildCoordinator.forcePresentation(route: .secondStep, animated: false, mainCoordinator: sut)
    
    finish(sut: sut.router) {
      XCTAssertEqual(sut.children.last?.uuid, makeChildCoordinator.uuid)
    }
  }
}


extension CoordinatorSUITests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> NavigationCoordinator<MyRouter> {
    let coordinator = NavigationCoordinator<MyRouter>.init(
      parent: nil
    )
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator
  }
  
  
  private func finish(sut: Router<MyRouter>, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finishFlow(animated: false ,completion: nil)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1)
  }
}


extension CoordinatorSUITests {
  
  
  private enum MyRouter: NavigationRoute {
    static let Name = "Hello world"
    
    
    case firstStep
    case secondStep
    
    func view() -> any View {
      switch self {
        case .firstStep: return FirstView()
        default: return CustomView()
      }
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
}
