import XCTest
import UIKit
import SwiftUI
@testable import ALCoordinator

final class ALCoordinatorTests: XCTestCase {
  
  
  func test_navigatingToViewControllerThatBelongOnNavStack() {
    typealias Item = FirstViewController
    let sut = makeSut()
    let item = Item()
    navigateToViewExpect(sut, toCompleteWithView: item, when: {
      sut.push(item, animated: false)
      sut.popToView(Item.self)
    })
  }
  
  
  func test_navigatingToHostingViewControllerViaSUIView() {
    typealias Item = UIHostingController<FirstView>
    let sut = makeSut()
    let item = Item(rootView: FirstView())
    navigateToViewExpect(sut, toCompleteWithView: item, when: {
      sut.push(item, animated: false)
      sut.popToView(Item.self, animated: false)
    })
  }
  
  
  func test_navigatingToViewControllerThatDoesNotBelongOnNavStack() {
    typealias Item = FirstViewController
    let sut = makeSut()
    sut.push(UIViewController(), animated: false)
    XCTAssertFalse(sut.popToView(Item.self, animated: false))
    let lastCtrl = sut.root.viewControllers.last
    XCTAssertNotEqual(sut.getNameOf(viewController: lastCtrl!), sut.getNameOf(object: Item.self))
  }
  
  
  func test_finishCoordinatorWhichHasChildren() {
    let sut = makeSut()
    
    finishCoordinatorExpect(sut) { [weak self] in
      _ = self?.makeChildCoordinator(parent: sut)
      _ = self?.makeChildCoordinator(parent: sut)
    }
  }
  
  
  func test_finishACoordinatorThatHasAChildAndThisOneHasAnotherChild() {
    let sut = makeSut()
    
    finishCoordinatorExpect(sut) { [weak self] in
      let firstCoordinator = self?.makeChildCoordinator(parent: sut)
      _ = self?.makeChildCoordinator(parent: firstCoordinator)
    }
  }
  
  
  func test_finishChildWithTabbarCoordinator() {
    let sut = makeSut()
    let pages = Pages.allCases.sorted(by: { $0.position < $1.position })
    let tabbarCoordinator = TabbarCoordinator(parent: sut, pages: pages)
    tabbarCoordinator.start()
    finishCoordinatorExpect(sut) {
      _ = TabbarCoordinator(parent: sut, pages: Pages.allCases)
    }
  }
  
  
  func test_startChildCoordinator() {
    var sut = makeSut()
    let childCoordinator = ChildCoordinator(parent: sut)
    childCoordinator.push(.init(), animated: false)
    sut.startChildCoordinator(childCoordinator)
    XCTAssertEqual(sut.children.count, 1)
  }
  
  
  func test_getTopCoordinator() {
    let sut = makeSut()
    let firstCoordinator = makeChildCoordinator(parent: sut)
    let secondCoordinator = makeChildCoordinator(parent: firstCoordinator)
    let thirdCoordinator = makeChildCoordinator(parent: secondCoordinator)
    XCTAssertEqual(sut.topCoordinator()?.uuid, thirdCoordinator.uuid)
  }
  
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  

  private func navigateToViewExpect(
    _ sut: Coordinator,
    toCompleteWithView expectedView: UIViewController?,
    when action: @escaping () -> Void
  ) {
    sut.push(UIViewController(), animated: false)
    sut.push(UIViewController(), animated: false)
    action()
    let lastCtrl = sut.root.viewControllers.last
    XCTAssertEqual(lastCtrl, expectedView)
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
  
  
  private func makeSut() -> Coordinator {
    MainCoordinator(parent: nil)
  }
  
  private func makeChildCoordinator(parent: Coordinator?) -> Coordinator {
    let item = ChildCoordinator(parent: parent)
    item.start(animated: false)
    return item
  }
  
  
  private class ChildCoordinator: BaseCoordinator {
    
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
      parent.startChildCoordinator(self)
    }
  }
  
  
  private enum Pages: TabbarPage, CaseIterable {
    
    case firstStep
    case secondStep
    
    func coordinator(parent: Coordinator) -> Coordinator {
      ChildCoordinator(parent: parent)
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
