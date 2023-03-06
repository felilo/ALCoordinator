import XCTest
import UIKit
import SwiftUI
@testable import ALCoordinator

final class AFLCoordinatorTests: XCTestCase {
  
  func test_navigateToViewController() {
    typealias Item = SecondViewController
    // Given a coordinator with some controllers in its navigation stack
    let sut = getCoordinator()
    // When the user pop to SecondViewController
    sut.popToView(Item.self)
    // Then the top controller in the stack is the SecondViewController
    let lastCtrl = sut.root.viewControllers.last
    XCTAssertNotNil(lastCtrl)
    XCTAssertEqual(
      sut.getNameOf(viewController: lastCtrl!),
      sut.getNameOf(object: Item.self)
    )
  }
  
  
  func test_navigateToView() {
    
    typealias Item = FirstView
    // Given a coordinator with some views in its navigation stack
    let sut = getCoordinatorWithViewSUI()
    // When the user pop to FirstView
    sut.popToView(Item.self)
    // Then the top controller in the stack is the FirstView
    let lastCtrl = sut.root.viewControllers.last
    XCTAssertNotNil(lastCtrl)
    XCTAssertEqual(
      sut.getNameOf(viewController: lastCtrl!),
      "UIHostingController<\(sut.getNameOf(object: Item.self))>"
    )
  }
  
  
  private func getCoordinator() -> Coordinator {
    let coordinator = MainCoordinator(parent: nil)
    coordinator.root.viewControllers = [
      FirstViewController(),
      SecondViewController(),
      ThirdViewController()
    ]
    return coordinator
  }
  
  
  private func getCoordinatorWithViewSUI() -> Coordinator {
    let coordinator = MainCoordinatorSUI(parent: nil)
    coordinator.show(.second)
    let ctrl = UIHostingController(rootView: FirstView())
    coordinator.root.viewControllers.insert(ctrl, at: 0)
    return coordinator
  }
}
