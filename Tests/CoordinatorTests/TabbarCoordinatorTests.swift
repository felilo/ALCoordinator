//
//  File.swift
//  
//
//  Created by Andres Lozano on 14/03/23.
//

import XCTest
import SwiftUI
@testable import ALCoordinator

final class TabbarCoordinatorTests: XCTestCase {
  
  
  func test_finishTabbarCoordinator() {
    let sut = makeSut()
    finishCoordinatorExpect(sut.parent!) {
      _ = TabbarCoordinator(parent: sut, pages: Page.allCases)
    }
  }
  
  
  func test_buildTabbarCoordinator() {
    var sut = makeSut()
    buildTabbarExpect(sut)
    
    sut = TabbarCoordinator(
      parent: MainCoordinator(parent: nil),
      customView: CustomView(),
      pages: Page.allCases.sorted(by: { $0.position < $1.position })
    )
    sut.start(animated: false)
    
    buildTabbarExpect(sut)
  }
  
  
  func test_changeTab() {
    let sut = makeSut()
    XCTAssertEqual(sut.currentPage?.position, Page.firstStep.position)
    sut.currentPage = .secondStep
    XCTAssertEqual(sut.currentPage?.position, Page.secondStep.position)
    sut.currentPage = .firstStep
    XCTAssertEqual(sut.currentPage?.position, Page.firstStep.position)
  }
  
  
  func test_getTopCoordinator() {
    let sut = makeSut()
    sut.currentPage = .secondStep
    let currentCoordinator = sut.getCoordinatorSelected()
    let mainCoordinator = sut.parent
    XCTAssertEqual(sut.getTopCoordinator(mainCoordinator: mainCoordinator)?.uuid, currentCoordinator.uuid)
  }

  
  func test_setPages() {
    let sut = makeSut()
    let pages = [Page.firstStep]
    let expect = XCTestExpectation()
    XCTAssertEqual(sut.children.count, Page.allCases.count)
    sut.setPages(pages) {
      XCTAssertEqual(sut.children.count, pages.count)
      XCTAssertEqual(pages.count, sut.tabController?.viewControllers?.count)
      expect.fulfill()
    }
    wait(for: [expect], timeout: 1)
  }
}



extension TabbarCoordinatorTests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func makeSut() -> TabbarCoordinator<Page> {
    let coordinator = TabbarCoordinator(
      parent: MainCoordinator(parent: nil),
      pages: Page.allCases.sorted(by: { $0.position < $1.position })
    )
    coordinator.start(animated: false)
    return coordinator
  }
  
  
  private func finishCoordinatorExpect(_ sut: Coordinator, when action: @escaping () -> Void) {
    sut.push(.init(), animated: false)
    sut.push(.init(), animated: false)
    action()
    let exp = XCTestExpectation()
    sut.finish(animated: false) {
      XCTAssertTrue(sut.children.isEmpty)
      XCTAssertEqual(sut.root.viewControllers.count, 1)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 2)
  }
  
  
  private func buildTabbarExpect(_ sut: TabbarCoordinator<Page>) {
    let pages = Page.allCases
    let viewControllers = sut.tabController.viewControllers
    
    XCTAssertEqual(sut.children.count, pages.count)
    XCTAssertEqual(pages.map({ $0.position }), viewControllers?.map({ $0.tabBarItem.tag }))
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
      parent.startChildCoordinator(self)
    }
  }
  
  
  private class OtherChildCoordinator: BaseCoordinator {
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
      parent.startChildCoordinator(self)
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
