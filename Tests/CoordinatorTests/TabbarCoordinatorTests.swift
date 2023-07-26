//
//  File.swift
//  
//
//  Created by Andres Lozano on 14/03/23.
//

import XCTest
import SwiftUI
@testable import UIKCoordinator

final class TabbarCoordinatorTests: XCTestCase {
  
  
  func test_finishTabbarCoordinator_with_childTabbarCoordinator() {
    let exp = XCTestExpectation(description: "")
    let sut = makeSut()
    
    let coordinator = TabbarCoordinator(pages: Page.allCases, parent: sut.children.first)
    coordinator.start(animated: false)
    DispatchQueue.main.async {
      sut.finish(animated: false) {
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertTrue(sut.root.viewControllers.isEmpty)
        exp.fulfill()
      }
    }
    
    wait(for: [exp], timeout: 1)
  }
  
  
  func test_changeTab() {
    let sut = makeSut()
    finish(sut: sut) {
      XCTAssertEqual(sut.currentPage?.position, Page.firstStep.position)
      sut.currentPage = .secondStep
      XCTAssertEqual(sut.currentPage?.position, Page.secondStep.position)
      XCTAssertEqual(sut.tabController.selectedIndex, Page.secondStep.position)
      sut.currentPage = .firstStep
      XCTAssertEqual(sut.currentPage?.position, Page.firstStep.position)
      XCTAssertEqual(sut.tabController.selectedIndex, Page.firstStep.position)
    }
  }
  
  
  func test_getTopCoordinator() {
    let sut = makeSut()
    sut.currentPage = .secondStep
    let currentCoordinator = sut.getCoordinatorSelected()
    let mainCoordinator = sut.parent
    finish(sut: sut) {
      XCTAssertEqual(sut.getTopCoordinator(mainCoordinator: mainCoordinator)?.uuid, currentCoordinator.uuid)
    }
    
  }
  
  
  func test_setPages() {
    let sut = makeSut()
    let pages = [Page.firstStep]
    XCTAssertEqual(sut.children.count, Page.allCases.count)
    sut.setPages(pages) { [weak self] in
      self?.finish(sut: sut) {
        XCTAssertEqual(sut.children.count, pages.count)
        XCTAssertEqual(pages.count, sut.tabController?.viewControllers?.count)
      }
    }
  }
}



extension TabbarCoordinatorTests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> TabbarCoordinator<Page> {
    
    let coordinator = TabbarCoordinator(
      pages: Page.allCases.sorted(by: { $0.position < $1.position })
    )
    
    let mainCoordinator = MainCoordinator(parent: nil)
    mainCoordinator.router.navigate(to: coordinator, animated: false)
    BaseCoordinator.mainCoordinator = coordinator.parent
    
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator
  }
  
  private func finish(sut: Coordinator, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finish(animated: false) {
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1)
  }
}



extension TabbarCoordinatorTests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Coordinators
  // ---------------------------------------------------------------------
  
  
  private class ChildCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .first, animated: animated)
    }
  }
  
  
  private class OtherChildCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .first, animated: animated)
    }
  }
  
  
  private class MainCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .first, animated: animated)
    }
  }
}



extension TabbarCoordinatorTests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Enums
  // ---------------------------------------------------------------------
  
  
  private enum Page: TabbarPage, CaseIterable {
    
    case firstStep
    case secondStep
    
    func coordinator(parent: Coordinator) -> Coordinator {
      switch self {
        case .firstStep: return ChildCoordinator(parent: parent)
        case .secondStep: return OtherChildCoordinator(parent: parent)
      }
    }
    
    var title: String {
      switch self {
        case .firstStep: return "First"
        case .secondStep: return "Second"
      }
    }
    
    var icon: String {
      switch self {
        case .firstStep: return "home"
        case .secondStep: return "gear"
      }
    }
    
    var position: Int {
      switch self {
        case .firstStep: return 0
        case .secondStep: return 1
      }
    }
  }
  
  
  private enum MyRouter: NavigationRoute {
    
    case first
    case second
    case third
    
    func view() -> UIViewController {
      .init()
    }
    
    var transition: NavigationTransitionStyle { .push }
  }
}
