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
    let sut = makeSut()
    sut.push(.init(), animated: false)
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
      let coordinator = self?.makeChildCoordinator(parent: sut)
      _ = self?.makeChildCoordinator(parent: coordinator)
    }
  }
  
  
  func test_startChildCoordinator() {
    let sut = makeSut()
    
    let childCoordinator = ChildCoordinator(parent: sut)
    childCoordinator.router.show(.second, animated: false)
    childCoordinator.presentCoordinator(animated: false)
    finish(sut: sut) {
      XCTAssertEqual(sut.children.count, 1)
    }
  }
  
  
  func test_getTopCoordinator() {
    let sut = makeSut()
    
    let firstCoordinator = makeChildCoordinator(parent: sut)
    let secondCoordinator = makeChildCoordinator(parent: firstCoordinator)
    let thirdCoordinator = makeChildCoordinator(parent: secondCoordinator)
    
    finish(sut: sut) {
      XCTAssertEqual(sut.topCoordinator()?.uuid, thirdCoordinator.uuid)
      BaseCoordinator.mainCoordinator = sut
      XCTAssertEqual(sut.getTopCoordinator()?.uuid, thirdCoordinator.uuid)
      BaseCoordinator.mainCoordinator = nil
    }
  }
  
  
  func test_restartMainCoordinator() {
    let sut = makeSut()
    let firstCoordinator = makeChildCoordinator(parent: sut)
    let secondCoordinator = makeChildCoordinator(parent: firstCoordinator)
    
    secondCoordinator.restartMainCoordinator(mainCoordinator: sut, animated: false, completion: nil)
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
    sut.push(.init(), animated: false)
    
    action()
    
    XCTAssertEqual(sut.root.viewControllers.last, expectedView)
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
  
  
  private func makeSut(file: StaticString = #file, line: UInt = #line) -> BaseCoordinator {
    let coordinator = MainCoordinator(parent: nil)
    addTeardownBlock { [weak coordinator] in
      XCTAssertNil(coordinator, "Instance should have been deallocated, potential memory leak", file: file, line: line)
    }
    return coordinator
  }
  
  
  private func makeChildCoordinator(parent: Coordinator?) -> NavigationCoordinatable<MyRouter> {
    let item = ChildCoordinator(parent: parent, presentationStyle: .fullScreen)
    item.start(animated: false)
    return item
  }
  
  
  private class ChildCoordinator: NavigationCoordinatable<MyRouter> {
    override func start(animated: Bool = false) {
      router.show(.first, animated: animated)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private class MainCoordinator: BaseCoordinator {
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
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
    
    var transition: NavigationTransitionStyle {
      .push
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
  
  
  class FirstViewController: UIViewController {}
  class SecondViewController: UIViewController {}
  class ThirdViewController: UIViewController {}
}
