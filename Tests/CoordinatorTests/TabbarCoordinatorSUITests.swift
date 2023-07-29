//
//  File.swift
//  
//
//  Created by Andres Lozano on 17/07/23.
//

import XCTest
import SwiftUI
import SwiftUI
@testable import SUICoordinator

final class TabbarCoordinatorSUITests: XCTestCase {
  
  func test_buildTabbarCoordinatorWithCustomView() {
    var sut = makeSut()
    buildTabbarExpect(sut)
    
    sut = TabbarCoordinator(
      customView: CustomView(),
      pages: Page.allCases.sorted(by: { $0.position < $1.position }),
      parent: MainCoordinator(parent: nil)
    )
    
    sut.start(animated: false)
    buildTabbarExpect(sut)
  }
  
  func test_buildDefaultTabbarCoordinator() {
    var sut = makeSut()
    buildTabbarExpect(sut)
    
    sut = TabbarCoordinator(
      pages: Page.allCases.sorted(by: { $0.position < $1.position }),
      parent: MainCoordinator(parent: nil)
    )
    
    sut.start(animated: false)
    buildTabbarExpect(sut)
  }
}




extension TabbarCoordinatorSUITests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> TabbarCoordinator<Page> {
    let coordinator = TabbarCoordinator(
      pages: Page.allCases.sorted(by: { $0.position < $1.position }),
      parent: MainCoordinator(parent: nil)
    )
    coordinator.start(animated: false)
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator
  }
  
  
  private func buildTabbarExpect(_ sut: TabbarCoordinator<Page>) {
    let pages = Page.allCases
    let viewControllers = sut.tabController.viewControllers
    finish(sut: sut) {
      XCTAssertEqual(sut.children.count, pages.count)
      XCTAssertEqual(pages.map({ $0.position }), viewControllers?.map({ $0.tabBarItem.tag }))
    }
  }
  
  
  private func finish(sut: Coordinator, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finish(animated: false ,completion: nil)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1)
  }
  
  
  private struct CustomView: View {
    var body: some View { Text("") }
  }
}



extension TabbarCoordinatorSUITests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Coordinators
  // ---------------------------------------------------------------------
  
  
  private class ChildCoordinator: NavigationCoordinator<CustomRoute> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .one, animated: animated)
    }
  }
  
  
  private class OtherChildCoordinator: NavigationCoordinator<CustomRoute> {
    
    override func start(animated: Bool = false) {
      router.startFlow(route: .two, animated: animated)
    }
  }
  
  
  private class MainCoordinator: NavigationCoordinator<CustomRoute> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .one, animated: animated)
    }
  }
}



extension TabbarCoordinatorSUITests {
  
  
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
    
    static var itemsSorted: [Self] {
      Self.allCases.sorted(by: { $0.position < $1.position })
    }
  }
  
  
  enum CustomRoute: NavigationRoute {
    
    case one
    case two
    
    var transition: NavigationTransitionStyle { .push }
    func view() -> any View { Text("") }
  }
}

