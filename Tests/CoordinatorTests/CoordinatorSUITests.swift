//
//  File.swift
//  
//
//  Created by Andres Lozano on 15/03/23.
//

import XCTest
import SwiftUI
@testable import ALCoordinator


final class CoordinatorSUITests: XCTestCase {
  
  func test_showVew() {
    let sut = makeSut()
    sut.show(.firstStep)
    XCTAssertFalse(sut.root.viewControllers.isEmpty)
  }
  
  
}


extension CoordinatorSUITests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func makeSut() -> CoordinatorSUI<Router> {
    
    let coordinator = CoordinatorSUI<Router>.init(
      parent: MainCoordinator(parent: nil)
    )
    return coordinator
  }
  
  
  private class ChildCoordinator: BaseCoordinator {
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private enum Router: NavigationRouter {
    
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
  
  
  private struct CustomView: View {
    var body: some View { Text("") }
  }
  
  private class MainCoordinator: BaseCoordinator { }
}
