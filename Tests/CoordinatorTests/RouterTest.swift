//
//  File.swift
//  
//
//  Created by Andres Lozano on 17/07/23.
//

import XCTest
import SwiftUI
@testable import UIKCoordinator


final class RouteTests: XCTestCase {
  
  func test_showVew() {
    let sut = makeSut()
    sut.show(.firstStep)
    finish(sut: sut) {
      XCTAssertFalse(sut.coordinator.root.viewControllers.isEmpty)
    }
  }
  
  func test_popView() {
    let sut = makeSut()
    sut.show(.firstStep)
    sut.show(.secondStep)
    sut.pop(animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.stackViews.count, 1)
    }
  }
  
  
  func test_pushView() {
    let sut = makeSut()
    sut.show(.firstStep, transitionStyle: .push, animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.coordinator.root.viewControllers.count, 1)
    }
  }
  
  
  func test_finishFlow() {
    let sut = makeSut()
    sut.finish(completion: nil)
    finish(sut: sut) {
      XCTAssertTrue(sut.coordinator.parent.children.isEmpty)
    }
  }
  
  func test_popToRoot() {
    
    let sut = makeSut()
    sut.show(.secondStep)
    sut.show(.thirdStep)
    sut.popToRoot(animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.stackViews.count, 1)
    }
  }
}



extension RouteTests {
  
  private func finish(sut: Router<Route>, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finish(animated: false ,completion: nil)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1)
  }
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> Router<Route> {
    let mainCoordinator = BaseCoordinator(parent: nil)
    let coordinator = NavigationCoordinatable<Route>(parent: mainCoordinator)
    coordinator.presentCoordinator(animated: false)
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator.router
  }
  
  
  private enum Route: NavigationRoute {
    
    case firstStep
    case secondStep
    case thirdStep
    
    func view() -> UIViewController { .init() }
    
    var transition: NavigationTransitionStyle {
      switch self {
        case .thirdStep: return .present
        default: return .push
      }
    }
  }
}
