# ALCoodinator

This repository contains a library implementing the Coordinator pattern, which is a design pattern used in iOS app development to manage app navigation flows. The library provides a set of classes and protocols that can be used to implement the Coordinator pattern in an iOS app. It works either UIKit or SwiftUI apps
Its core navigation has created with UINavigationController (UIKit) with the aim to get profit about navigation stack.

## Getting Started

To use the Coordinator pattern library in your iOS project, you'll need to add the library files to your project and set up a Coordinator object. Here are the basic steps:

## Defining the coordinator
First let's define our paths and its views

```swift
import SUICoordinator
import SwiftUI

enum OnboardingRoute: NavigationRoute {
  
  case firstStep(viewModel: FirstViewModel)
  case secondStep(viewModel: SecondViewModel)
  
  // MARK: NavigationRouter
  
  var transition: NavigationTransitionStyle {
    switch self {
      case .firstStep:
        return .push
      case .secondStep:
        return .present
    }
  }
  
  func view() -> any View {
    switch self {
      case .firstStep(let vm):
        return FirstView(viewModel: vm)
      case .secondStep(let vm):
        return SecondView(viewModel: vm)
    }
  }
}
```

Second let's create our first Coordinator. All coordinator should to implement the ``start()`` function and then starts the flow (mandatory). Finally add additional flows

```swift
import SUICoordinator

class OnboardingCoordinator: NavigationCoordinator<OnboardingRoute> {

  // MARK: Coordinator
  
  override func start(animated: Bool) {
    let vm = FirstViewModel(coordinator: self)
    router.startFlow(
      route: .firstStep(viewModel: vm),
      animated: animated
    )
  }

  // MARK: Helper funcs
  
  func showStep2() {
    let vm = SecondViewModel(coordinator: self)
    router.navigate(to: .secondStep(viewModel: vm))
  }
  
  func showHomeCoordinator() {
    let coordinator = HomeCoordinatorSUI(currentPage: .settings)
    router.navigate(to: coordinator)
  }
}
```

<br>

## Create a TabbarCoordinator

### 1. Create a router

```swift
import SUICoordinator

enum HomeRoute: CaseIterable, TabbarPage {
  
  case marketplace
  case settings
  
  // MARK: NavigationRouter
  
  func coordinator() -> Coordinator {
    switch self {
      case .settings:
        return SettingsCoordinator()
      case .marketplace:
        return MarketplaceCoordinator()
    }
  }
  
  // MARK: TabbarPageDataSource
  
  public var title: String {
    switch self {
      case .marketplace:
        return "Marketplace"
      case .settings:
        return "Settings"
    }
  }
  
  public var icon: String {
    switch self {
      case .marketplace:
        return "house"
      case .settings:
        return "gearshape"
    }
  }
  
  public var position: Int {
    switch self {
      case .marketplace:
        return 0
      case .settings:
        return 1
    }
  }
  
  static var itemsSorted: [HomeRoute] {
    Self.allCases.sorted(by: { $0.position < $1.position })
  }
}
```

### 2. Create a TabbarCoordinator

* Default tabbar build with UIKIT (It also works with SwiftUI)

```swift
import UIKCoordinator
import UIKit

class HomeCoordinatorUIKit: TabbarCoordinator<HomeRoute> {
  
  // MARK: Constructor
  
  public init() {
    super.init(
      pages: [.marketplace, .settings],
      currentPage: .marketplace
    )
  }
}
```

* Custom view (SwiftUI)

```swift
import SUICoordinator
import SwiftUI
import Combine

class HomeCoordinatorSUI: TabbarCoordinator<HomeRoute> {

  // MARK: Properties
  
  var cancelables = Set<AnyCancellable>()

  // Custom Tabbar view
  public init(currentPage: HomeRoute) {
    let viewModel = HomeTabbarViewModel()
    let view = HomeTabbarView(viewModel: viewModel)
    viewModel.currentPage = currentPage

    super.init(
      customView: view,
      pages: [.marketplace, .settings],
      currentPage: currentPage
    )
    
    viewModel.$currentPage
      .sink { [weak self] page in
        self?.currentPage = page
      }.store(in: &cancelables)
    
    UITabBar.appearance().isHidden = true
  }
  
  // Default Tabbar view
  public init(default: Bool ) {
    super.init(pages: [.marketplace, .settings])
  }
}
```

<br>

### 3. Create MainCoordinator

```swift
import SUICoordinator

class MainCoordinator: NavigationCoordinator<MainRoute> {
  
  // MARK: Constructor
  
  init() {
    super.init(parent: nil)
    router.startFlow(route: .splash, animated: false)
  }
  
  // MARK: Coordinator
  
  override func start(animated: Bool = false) {
    router.navigate(to: OnboardingCoordinator(presentationStyle: .fullScreen), animated: animated)
  }
}
```

```swift
import SUICoordinator
import SwiftUI

enum MainRoute: NavigationRoute {
  
  case splash

  // MARK: NavigationRoute

  var transition: NavigationTransitionStyle { .push }
  func view() -> any View { SplashScreenView() }
}
```

### Setup project

<br>

1. Create a SceneDelegate class if your app supports scenes:

```swift
import SwiftUI
import SUICoordinator

final class SceneDelegate: NSObject, UIWindowSceneDelegate {
  
  var mainCoordinator: MainCoordinator?
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    setupCoordinator(window: window, animated: true)
  }
  
  private func setupCoordinator(window: UIWindow?, animated: Bool = false) {
    mainCoordinator = .init()
    setupWindow(controller: mainCoordinator?.root)
    BaseCoordinator.mainCoordinator = mainCoordinator
    mainCoordinator?.start(animated: animated)
  }
  
  private func setupWindow(controller: UIViewController?) {
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }
}
```

<br>

2. In your app's AppDelegate file, set the SceneDelegate class as the windowScene delegate:

```swift
import UIKit

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    return true
  }
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    let sessionRole = connectingSceneSession.role
    let sceneConfig = UISceneConfiguration(name: nil, sessionRole: sessionRole)
    sceneConfig.delegateClass = SceneDelegate.self
    return sceneConfig
  }
}
```


##### You can find an example here <https://github.com/felilo/TestCoordinatorLibrary>

<br>

#### Actions you can perform from the coordinator depends on the kind of coordinator used. For instance, using a Router, NavigationCoordinator or TabbarCoordinator some of the functions you can perform are:

#### Router

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Parametes</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code style="color: blue;">navigate(_)</code></td>
      <td>
      <b>to:</b> <code>Route</code><br> 
      <b>transitionStyle:</b> <code>NavigationTransitionStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,<br> 
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br> 
      <b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code><br>
      </td>
      <td>
      Allows you to navigate among the views that were defined in the Route. The types of presentation are Push, Modal, ModalFullScreen and Custom.
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">navigate(_)</code></td>
      <td>
      <b>to:</b> <code>Coordinator</code><br>
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      </td>
      <td>
      Allows you to navigate among the Coordinators. It calls the <code>start()</code> function
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">startFlow(_)</code></td>
      <td>
      <b>to:</b> <code>Route</code><br> 
      <b>transitionStyle:</b> <code>NavigationTransitionStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,<br> 
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code><br>
      </td>
      <td>
      Cleans the navigation stack and runs the navigation flow
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">present(_)</code></td>
      <td>
      <b>_ view:</b> <code>ViewType</code><br> 
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      <b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code><br>
      </td>
      <td>
      Presents a view modally.
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">pop(_)</code></td>
      <td>
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      </td>
      <td>
      Pops the top view from the navigation stack and updates the display.
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToRoot(_)</code></td>
      <td>
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      <b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code><br>
      </td>
      <td>
      Pops all the views on the stack except the root view and updates the display.
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">dismiss(_)</code></td>
      <td>
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      </td>
      <td>
      Dismisses the view that was presented modally by the view.
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToView(_)</code></td>
      <td>
      <b>_ view:</b> <code>T</code><br> 
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      </td>
      <td>
      Pops views until the specified view is at the top of the navigation stack.
      </td>
    </tr>
    <tr>
      <td><code style="color: blue;">finishFlow(_)</code></td>
      <td>
      <b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,<br>
      <b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code><br>
      </td>
      <td>
      Pops all the views on the stack including the root view, dismisses all the modal view and remove the current coordinator from the coordinator stack
      </td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>root</code></td>
      <td>variable to get navigation controller.</td>
    </tr>
    <tr>
      <td><code>start()</code></td>
      <td>Starts the navigation flow managed by the coordinator. This method should be called to begin a navigation flow. Params:
        <br><b>animated:</b> Bool <note>default true</note>
      </td>
    </tr>
    <tr>
      <td><code>finish()</code></td>
      <td>Finishes the navigation flow managed by the coordinator. This method should be called to end a navigation flow.
        <br>Params:
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>push(_:)</code></td>
      <td>Pushes a view controller onto the receiver’s stack and updates the display (only for UIKit).
        <br>Params:
        <br><b>viewController:</b> <span>UIViewController</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>present(_:)</code></td>
      <td>Presents a view controller modally (only for UIKit).
        <br>Params:
        <br><b>viewController:</b> <span>UIViewController</span>
        <br><b>animated:</b> <span>Bool, default true</span>
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
      </td>
    </tr>
    <tr>
      <td><code>pop(_:)</code></td>
      <td>Pops the top view controller from the navigation stack and updates the display .
        <br>Params:
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>popToRoot(_:)</code></td>
      <td>Pops all the view controllers on the stack except the root view controller and updates the display.
        <br>Params:
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>popToView(_:)</code></td>
      <td>Pops view controllers until the specified view controller is at the top of the navigation stack.
        <br> if the view is onto navigation stack returns true. e.i: popToView(MyObject.self, animated: false).
        <br>Params:
        <br><b>view:</b> <span>Any</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>dismiss(_:)</code></td>
      <td>Dismisses the view controller that was presented modally by the view controller.
        <br>Params:
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>close(_:)</code></td>
      <td>If a view controller is presented as modal, it calls the <code>dismiss(:)</code>> function; otherwise, <code>pop(:)</code>.
        <br>Params:
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>topCoordinator(_:)</code></td>
      <td>Returns the last coordinator presented</td>
    </tr>
    <tr>
      <td><code>restart(_:)</code></td>
      <td>Finish all its children and finally call <code>start()</code> function.
        <br>params
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>startChildCoordinator(_:)</code></td>
      <td>It is a faster way to initialize a secondary coordinator. Inserting a child to its child coordinators and finally it calls <code>present(:)</code> function.
        <br>params
        <br><b>coordinator:</b> <span>Coordinator, child coordinator</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>presentCoordinator(_:)</code></td>
      <td>It is a faster way to present current Coordinator. You should call this function into start function.
        <br>params
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
  </tbody>
</table>

#### Classes

In addition to the functions listed above, the Coordinator-pattern library provides several classes that can be used to simplify the implementation of the Coordinator pattern in an iOS app. These classes are:

`BaseCoordinator`
The BaseCoordinator class provides a basic implementation of the Coordinator protocol, with default implementations. This class can be subclassed to create custom coordinator objects that implement the Coordinator protocol.

<br>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>restartMainCoordinator()</code></td>
      <td>Finish all its children and finally call <code>start()</code> function.
        <br>Params
        <br><b>mainCoordinator:</b> <span>Coordinator, default BaseCoordinator.mainCoordinator</span>
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>getTopCoordinator()</code></td>
      <td>Returns the last coordinator presented
        <br>Params
        <br><b>mainCoordinator:</b> <span>Coordinator, default BaseCoordinator.mainCoordinator</span>
      </td>
    </tr>
  </tbody>
</table>

<br>

`TabbarCoordinator`
The TabbarCoordinator class is a specialized coordinator object that is designed to manage the navigation flow of a tab bar interface. This class provides methods for adding child coordinators for each tab in the tab bar, and for managing the selection of tabs.

<br>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>getCoordinatorSelected()</code></td>
      <td>Finish all its children and finally call <code>start()</code> function.
        <br>params
        <br><b>mainCoordinator:</b> <span>Coordinator, default BaseCoordinator.mainCoordinator</span>
        <br><b>completion:</b> <span>(() -> Void)?, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
    <tr>
      <td><code>setPages(:)</code></td>
      <td>Set pages
        <br>Params
        <br><b>pages:</b> <span>[TabbarPage], List of pages</span>
      </td>
    </tr>
    <tr>
      <td><code>currentPage</code></td>
      <td>Variable to get or set current page</td>
    </tr>
  </tbody>
</table>

<br>

`CoordinatorSUI`
The CoordinatorSUI class is a specialized coordinator object that is designed to manage the navigation flow of a SwiftUI app. This class provides methods for showing views.

<br>

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>show(:)</code></td>
      <td>shows a SwiftUI view.
        <br>Params
        <br><b>router:</b> <span>NavigationRouter</span>
        <br><b>transitionStyle:</b> <span>NavigationTranisitionStyle, default nil</span>
        <br><b>animated:</b> <span>Bool, default true</span>
      </td>
    </tr>
  </tbody>
</table>

<br>

`TabbarPage`
The typealias TabbarPage is a short way to implement protocols TabbarPageDataSource & TabbarNavigationRouter

<br>

### Installation 💾

SPM

Open Xcode and your project, click File / Swift Packages / Add package dependency... . In the textfield "Enter package repository URL", write <https://github.com/felilo/ALCoordinator> and press Next twice

## Contributing

Contributions to the ALCoordinator library are welcome! To contribute, simply fork this repository and make your changes in a new branch. When your changes are ready, submit a pull request to this repository for review.

License

The ALCoordinator library is released under the MIT license. See the LICENSE file for more information.
