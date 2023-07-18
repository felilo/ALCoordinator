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
  
  
  func test_finishTabbarCoordinator() {
    let exp = XCTestExpectation(description: "")
    let sut = makeSut()

    sut.finish(animated: false) {
      _ = TabbarCoordinator(parent: sut.children.last, pages: Page.allCases)
      XCTAssertEqual(sut.children.count, 0)
      XCTAssertEqual(sut.root.viewControllers.count, 0)
      exp.fulfill()
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
      parent: MainCoordinator(parent: nil),
      pages: Page.allCases.sorted(by: { $0.position < $1.position })
    )
    coordinator.start(animated: false)
    
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator
  }
  
  
  private func finishCoordinatorExpect(_ sut: Coordinator, when action: @escaping () -> Void) {
    sut.push(.init(), animated: false)
    sut.push(.init(), animated: false)
    action()
    finish(sut: sut) {
      XCTAssertTrue(sut.children.isEmpty)
      XCTAssertEqual(sut.root.viewControllers.count, 1)
    }
  }
  
  
  private func buildTabbarExpect(_ sut: TabbarCoordinator<Page>) {
    let pages = Page.allCases
    let viewControllers = sut.tabController.viewControllers
    
    XCTAssertEqual(sut.children.count, pages.count)
    XCTAssertEqual(pages.map({ $0.position }), viewControllers?.map({ $0.tabBarItem.tag }))
  }
  
  private func finish(sut: Coordinator, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finish(animated: false) {
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 3)
  }
  
  private struct CustomView: View {
    var body: some View { Text("") }
  }
}



extension TabbarCoordinatorTests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Coordinators
  // ---------------------------------------------------------------------
  
  
  private class ChildCoordinator: BaseCoordinator {
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private class OtherChildCoordinator: BaseCoordinator {
    
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private class MainCoordinator: BaseCoordinator { }
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
}
