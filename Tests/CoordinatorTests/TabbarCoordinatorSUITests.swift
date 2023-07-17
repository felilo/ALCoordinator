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
        parent: MainCoordinator(parent: nil),
        customView: CustomView(),
        pages: Page.allCases.sorted(by: { $0.position < $1.position })
      )
      sut.start(animated: false)
  
      buildTabbarExpect(sut)
    }
  
  func test_buildDefaultTabbarCoordinator() {
    var sut = makeSut()
    buildTabbarExpect(sut)
    
    sut = TabbarCoordinator(
      parent: MainCoordinator(parent: nil),
      pages: Page.allCases.sorted(by: { $0.position < $1.position })
    )
    sut.start(animated: false)
    
    buildTabbarExpect(sut)
  }
}




extension TabbarCoordinatorSUITests {
  
  
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



extension TabbarCoordinatorSUITests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Coordinators
  // ---------------------------------------------------------------------
  
  
  private class ChildCoordinator: NavigationCoordinatable<CustomRoute> {
    override func start(animated: Bool = false) {
      router.show(.one, transitionStyle: .push, animated: false)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private class OtherChildCoordinator: NavigationCoordinatable<CustomRoute> {
    
    override func start(animated: Bool = false) {
      router.show(.two, transitionStyle: .push, animated: false)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private class MainCoordinator: BaseCoordinator { }
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
  }
  
  
  enum CustomRoute: NavigationRoute {
    var transition: NavigationTransitionStyle {
      switch self {
        default: return .push
      }
    }
  
    case one
    case two
    
    func view() -> any View {
      Text("")
    }
    
  }
}

