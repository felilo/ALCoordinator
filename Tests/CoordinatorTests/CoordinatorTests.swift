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
      sut.push(.init(), animated: false)
      sut.popToView(Item.self)
    })
  }
  
  
  func test_navigatingToHostingViewControllerViaSUIView() {
    typealias Item = UIHostingController<FirstView>
    let sut = makeSut()
    let item = Item(rootView: FirstView())
    navigateToViewExpect(sut, toCompleteWithView: item, when: {
      sut.push(item, animated: false)
      sut.push(.init(), animated: false)
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
      let coordinator = self?.makeChildCoordinator(parent: sut)
      _ = self?.makeChildCoordinator(parent: coordinator)
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
    BaseCoordinator.mainCoordinator = sut
    XCTAssertEqual(sut.getTopCoordinator()?.uuid, thirdCoordinator.uuid)
  }
  
  
  func test_restartMainCoordinator() {
    let sut = makeSut()
    let firstCoordinator = makeChildCoordinator(parent: sut)
    let secondCoordinator = makeChildCoordinator(parent: firstCoordinator)
    
    let expect = XCTestExpectation()
    
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
    sut.push(UIViewController(), animated: false)
    action()
    let lastCtrl = sut.root.viewControllers.last
    XCTAssertEqual(lastCtrl, expectedView)
  }
  
  
  private func finishCoordinatorExpect(_ sut: Coordinator, when action: @escaping () -> Void) {
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
  
  
  private func makeSut() -> BaseCoordinator {
    MainCoordinator(parent: nil)
  }
  
  
  private func makeChildCoordinator(parent: Coordinator?) -> BaseCoordinator {
    let item = ChildCoordinator(parent: parent, presentationStyle: .fullScreen)
    item.start(animated: false)
    return item
  }
  
  
  private class ChildCoordinator: BaseCoordinator {
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
      presentCoordinator(animated: animated)
      presentCoordinator(animated: animated)
    }
  }
  
  
  private class MainCoordinator: BaseCoordinator {
    override func start(animated: Bool = false) {
      push(.init(), animated: animated)
    }
  }
  
  
  class FirstViewController: UIViewController {}
  class SecondViewController: UIViewController {}
  class ThirdViewController: UIViewController {}
  
  
  struct FirstView: View {
    var body: some View { Text("FirstView") }
  }
  
  
  struct SecondView: View {
    var body: some View { Text("SecondView") }
  }
}
