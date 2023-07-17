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
    
    XCTAssertEqual(sut.children.count, 1)
  }
  
  
  func test_getTopCoordinator() {
    let sut = makeSut()
    
    let firstCoordinator = makeChildCoordinator(parent: sut)
    let secondCoordinator = makeChildCoordinator(parent: firstCoordinator)
    let thirdCoordinator = makeChildCoordinator(parent: secondCoordinator)
    
    XCTAssertEqual(sut.topCoordinator()?.uuid, thirdCoordinator.uuid)
    BaseCoordinator.mainCoordinator = sut
    XCTAssertEqual(sut.getTopCoordinator()?.uuid, thirdCoordinator.uuid)
  }
  
  
  func test_restartMainCoordinator() {
    let expect = XCTestExpectation()
    let sut = makeSut()
    let firstCoordinator = makeChildCoordinator(parent: sut)
    let secondCoordinator = makeChildCoordinator(parent: firstCoordinator)
    
    secondCoordinator.restartMainCoordinator(mainCoordinator: sut, animated: false) {
      XCTAssertTrue(sut.children.isEmpty)
      expect.fulfill()
    }
    
    wait(for: [expect], timeout: 1)
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
    let exp = XCTestExpectation()
    sut.push(.init(), animated: false)
    action()
    
    sut.finish(animated: false) {
      XCTAssertTrue(sut.children.isEmpty)
      XCTAssertEqual(sut.root.viewControllers.count, 1)
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 2)
  }
  
  
  private func makeSut() -> BaseCoordinator {
    MainCoordinator(parent: nil)
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
  
  
  class FirstViewController: UIViewController {}
  class SecondViewController: UIViewController {}
  class ThirdViewController: UIViewController {}
}
