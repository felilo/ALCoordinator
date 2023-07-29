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
  
  func test_popView() {
    let sut = makeSut()
    
    sut.navigate(to: .secondStep, animated: false)
    XCTAssertEqual(sut.stackViews.count, 2)
    
    sut.pop(animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.stackViews.count, 1)
    }
  }
  
  
  func test_pushView() {
    let sut = makeSut()
    sut.navigate(to: .secondStep, animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.stackViews.count, 2)
    }
  }
  
  
  func test_finishFlow() {
    let exp = XCTestExpectation(description: "finishFlow")
    let sut = makeSut()
    
    sut.finishFlow(completion: nil)
    sut.navigate(to: .secondStep, animated: false)
    XCTAssertEqual(sut.stackViews.count, 2)
    
    sut.finishFlow(animated: false) {
      XCTAssertEqual(sut.stackViews.count, 1)
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1)
  }
  
  func test_popToRoot() {
    let sut = makeSut()
    
    sut.navigate(to: .secondStep, animated: false)
    sut.navigate(to: .thirdStep, animated: false)
    sut.popToRoot(animated: false)
    
    finish(sut: sut) {
      XCTAssertEqual(sut.stackViews.last?.name, "\(FirstStepController.self)")
    }
  }
}



extension RouteTests {
  
  private func finish(sut: Router<Route>, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finishFlow(animated: false ,completion: nil)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1)
  }
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> Router<Route> {
    let coordinator = NavigationCoordinator<Route>(parent: nil)
    coordinator.router.startFlow(route: .firstStep, animated: false)
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator.router
  }
  
  
  private enum Route: NavigationRoute {
    
    case firstStep
    case secondStep
    case thirdStep
    
    func view() -> UIViewController {
      switch self {
        case .firstStep: return FirstStepController()
        case .secondStep: return SecondStepController()
        case .thirdStep: return ThirdStepController()
      }
    }
    
    var transition: NavigationTransitionStyle {
      switch self {
        case .thirdStep: return .modal
        default: return .push
      }
    }
  }
  
  class FirstStepController: UIViewController {}
  class SecondStepController: UIViewController {}
  class ThirdStepController: UIViewController {}
}
