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
    XCTAssertFalse(sut.coordinator.root.viewControllers.isEmpty)
  }
  
  func test_popView() {
    let sut = makeSut()
    sut.show(.firstStep)
    sut.show(.secondStep)
    sut.pop(animated: false)
    XCTAssertEqual(sut.stackViews.count, 1)
  }
  
  
  func test_pushView() {
    let sut = makeSut()
    sut.show(.firstStep, transitionStyle: .push, animated: false)
    XCTAssertEqual(sut.coordinator.root.viewControllers.count, 1)
  }
  
  
  func test_finishFlow() {
    let sut = makeSut()
    let exp = XCTestExpectation(description: "")
    sut.finish(animated: false) {
      XCTAssertTrue(sut.coordinator.parent.children.isEmpty)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1)
  }
  
  func test_popToRoot() {
    let sut = makeSut()
    sut.show(.secondStep)
    sut.show(.thirdStep)
    sut.popToRoot(animated: false)
    XCTAssertEqual(sut.stackViews.count, 1)
  }
}



extension RouteTests {
  
  private func makeSut() -> Router<Route> {
    let mainCoordinator = BaseCoordinator(parent: nil)
    let coordinator = NavigationCoordinatable<Route>(parent: mainCoordinator)
    coordinator.presentCoordinator(animated: false)
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
