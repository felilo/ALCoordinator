import XCTest
import UIKit
@testable import UIKCoordinator

final class ALCoordinatorTests: XCTestCase {
  
  
  func test_navigatingToViewControllerThatBelongOnNavStack() {
    typealias Item = FirstViewController
    let sut = makeSut()
    let item = Item()
    
    navigateToViewExpect(sut, toCompleteWithView: item, when: {
      sut.push(item, animated: false)
      sut.push(.init(), animated: false)
      sut.popToView(Item.self)
    })
  }
  
  
  func test_navigatingToViewControllerThatDoesNotBelongOnNavStack() {
    typealias Item = FirstViewController
    let exp = XCTestExpectation(description: "")
    let sut = makeSut()
    sut.push(.init(), animated: false) {
      XCTAssertFalse(sut.popToView(Item.self, animated: false))
      let lastCtrl = sut.root.viewControllers.last
      XCTAssertNotEqual(sut.getNameOf(viewController: lastCtrl!), sut.getNameOf(object: Item.self))
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1)
  }
  
  
  func test_finishCoordinatorWhichHasChildren() {
    let sut = makeSut()
    
    finishCoordinatorExpect(sut) { [weak self] in
      let c1 = self?.makeChildCoordinator()
      c1?.router.startFlow(route: .first, animated: false)
      let c2 = self?.makeChildCoordinator()
      c2?.router.startFlow(route: .first, animated: false)
    }
  }
  
  
  func test_finishACoordinatorThatHasAChildAndThisOneHasAnotherChild() {
    let sut = makeSut()
    
    finishCoordinatorExpect(sut) { [weak self] in
      guard let self = self else { return }
      let coordinator = self.makeChildCoordinator()
      sut.router.navigate(to: coordinator, animated: false)
      let otherCoordinator = self.makeChildCoordinator()
      coordinator.router.navigate(to: otherCoordinator, animated: false)
    }
  }
  
  
  func test_startChildCoordinator() {
    let sut = makeSut()
    
    let childCoordinator = ChildCoordinator(parent: sut)
    sut.router.navigate(to: childCoordinator, animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.children.count, 1)
      XCTAssertEqual(sut.children.last?.uuid, childCoordinator.uuid)
    }
  }
  
  
  func test_getTopCoordinator() {
    let sut = makeSut()
    
    let firstCoordinator = makeChildCoordinator()
    sut.router.navigate(to: firstCoordinator, animated: false)
    let secondCoordinator = makeChildCoordinator()
    firstCoordinator.router.navigate(to: secondCoordinator, animated: false)
    let thirdCoordinator = makeChildCoordinator()
    secondCoordinator.router.navigate(to: thirdCoordinator, animated: false)
    
    finish(sut: sut) {
      XCTAssertEqual(sut.topCoordinator()?.uuid, thirdCoordinator.uuid)
      BaseCoordinator.mainCoordinator = sut
      XCTAssertEqual(sut.getTopCoordinator()?.uuid, thirdCoordinator.uuid)
      BaseCoordinator.mainCoordinator = nil
    }
  }
  
  
  func test_restartMainCoordinator() {
    let sut = makeSut()
    let firstCoordinator = makeChildCoordinator()
    sut.router.navigate(to: firstCoordinator, animated: false)
    let secondCoordinator = makeChildCoordinator()
    firstCoordinator.router.navigate(to: secondCoordinator, animated: false)
    secondCoordinator.restartApp(mainCoordinator: sut, animated: false, completion: nil)
    finish(sut: sut) {
      XCTAssertTrue(sut.children.isEmpty)
    }
  }
}



extension ALCoordinatorTests {
  
  
  // ---------------------------------------------------------------------
  // MARK: Helpers
  // ---------------------------------------------------------------------
  
  
  private func navigateToViewExpect(
    _ sut: Coordinator,
    toCompleteWithView expectedView: UIViewController?,
    when action: @escaping () -> Void
  ) {
    let exp = XCTestExpectation(description: "")
    sut.push(.init(), animated: false)
    action()
    XCTAssertEqual(sut.root.viewControllers.last, expectedView)
    exp.fulfill()
    wait(for: [exp], timeout: 1)
  }
  
  
  private func finishCoordinatorExpect(_ sut: Coordinator, when action: @escaping () -> Void) {
    sut.push(.init(), animated: false)
    action()
    sut.finish(animated: false) {[weak self] in
      self?.finish(sut: sut) {
        XCTAssertTrue(sut.children.isEmpty)
        XCTAssertEqual(sut.root.viewControllers.count, 1)
      }
    }
  }
  
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> NavigationCoordinatable<MyRouter> {
    let coordinator = MainCoordinator(parent: nil)
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator
  }
  
  
  private func makeChildCoordinator() -> NavigationCoordinatable<MyRouter> {
    let item = ChildCoordinator(presentationStyle: .fullScreen)
    return item
  }
  
  
  private class ChildCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .first)
    }
  }
  
  
  private class MainCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.startFlow(route: .third, animated: false)
    }
  }
  
  private enum MyRouter: NavigationRoute {
    
    case first
    case second
    case third
    
    func view() -> UIViewController {
      switch self {
        case .first: return FirstViewController()
        case .second: return SecondViewController()
        case .third: return ThirdViewController()
      }
    }
    
    var transition: NavigationTransitionStyle { .push }
  }
  
  private func finish(sut: Coordinator, _ completation: @escaping () -> Void ) -> Void {
    let exp = XCTestExpectation(description: "")
    DispatchQueue.main.async {
      completation()
      sut.finish(animated: false) { exp.fulfill() }
    }
    wait(for: [exp], timeout: 5)
  }
  
  
  class FirstViewController: UIViewController {}
  class SecondViewController: UIViewController {}
  class ThirdViewController: UIViewController {}
}
