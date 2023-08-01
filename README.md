# ALCoodinator

This repository contains a library implementing the Coordinator pattern, which is a design pattern used in iOS app development to manage app navigation flows. 
The library provides a set of classes and protocols that can be used to implement the Coordinator pattern in an iOS app. It works either UIKit or SwiftUI apps
Its core navigation has created with UINavigationController (UIKit) with the aim to get profit about navigation stack.
_____

## Getting Started

To use the Coordinator pattern library in your iOS project, you'll need to add the library files to your project and set up a Coordinator object.
Here are the basic steps:
_____

## Defining the coordinator
First let's define our paths and its views.
> **_NOTE:_** If you want to create a UIKit-compatible coordinator, you must **`import UIKCoordinator`** otherwise **`import SUICoordinator`**. 
> Next we are going to write an example of SwiftUI

<br>

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
        return .modal
    }
  }
  
  func view() -> any View {
    switch self {
      case .firstStep(let vm):
        return FirstView()
          .environmentObject(vm)
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

_____

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
  
  public var icon: Image {
    switch self {
      case .marketplace:
        return Image(systemName: "house")
      case .settings:
        return Image(systemName: "gearshape")
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
_____

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

#### You can find an example here <https://github.com/felilo/TestCoordinatorLibrary>

_____

### Features

These are the most important features and actions that you can perform:
<br>

#### Router

The router is encharge to manage the navigation stack and coordinate the transitions between different views. It abstracts away the navigation details from the views, allowing them to focus on their specific features such as:

<br>
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
        <ul cellspacing="0" cellpadding="0">
          <li><b>to:</b> <code>Route</code>,</li>
          <li><b>transitionStyle:</b> <code>NavigationTransitionStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Allows you to navigate among the views that were defined in the Route. The types of presentation are Push, Modal, ModalFullScreen and Custom.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">navigate(_)</code></td>
      <td> 
        <ul>
          <li><b>to:</b> <code>Coordinator</code></li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Allows you to navigate among the Coordinators. It calls the <code>start()</code> function.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">startFlow(_)</code></td>
      <td> 
        <ul>
          <li><b>to:</b> <code>Route</code></li>
          <li><b>transitionStyle:</b> <code>NavigationTransitionStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code></li>
        </ul>
      </td>
      <td>Cleans the navigation stack and runs the navigation flow.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">present(_)</code></td>
      <td> 
        <ul>
          <li><b>_ view:</b> <code>ViewType</code></li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Presents a view modally.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">pop(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Pops the top view from the navigation stack and updates the display.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToRoot(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Pops all the views on the stack except the root view and updates the display.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">dismiss(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Dismisses the view that was presented modally by the view.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">popToView(_)</code></td>
      <td> 
        <ul>
          <li><b>_ view:</b> <code>T</code></li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
        </ul>
      </td>
      <td>Pops views until the specified view is at the top of the navigation stack. Example: <code>router.popToView(MyView.self)</code></td>
    </tr>
    <tr>
      <td><code style="color: blue;">finishFlow(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Pops all the views on the stack including the root view, dismisses all the modal view and remove the current coordinator from the coordinator stack.</td>
    </tr>
  </tbody>
</table>
<br>

#### NavigationCoordinator

Acts as a separate entity from the views, decoupling the navigation logic from the presentation logic. This separation of concerns allows the views to focus solely on their specific functionalities, while the Navigation Coordinator takes charge of the app's overall navigation flow. Some features are:

<br>
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
      <td><code style="color: blue;">router</code></td>
      <td></td>
      <td>Variable of Route type which allow performs action router.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">forcePresentation(_)</code></td>
      <td> 
        <ul>
          <li><b>route:</b> <code>Route</code></li>
          <li><b>transitionStyle:</b> <code>NavigationTransitionStyle?</code>, default: <code style="color: #ec6b6f;">automatic</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default: <code style="color: #ec6b6f;">mainCoordinator</code></li>
        </ul>
      </td>
      <td>Puts the current coordinator at the top of the coordinator stack, making it the active and visible coordinator. This feature is very useful to start the navigation flow from push notifications, notification center, atypical flows, etc.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getTopCoordinator(_)</code></td>
      <td> 
        <ul>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default <code style="color: #ec6b6f;">mainCoordinator</code>,</li>
        </ul>
      </td>
      <td>Returns the coordinator that is at the top of the coordinator stack.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">restartApp(_)</code></td>
      <td> 
        <ul>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default <code style="color: #ec6b6f;">mainCoordinator</code>,</li>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Cleans the navigation stack and runs the main coordinator navigation flow.</td>
    </tr>
  </tbody>
</table>
<br>

#### TabbarCoordinator

Acts as a separate entity from the views, decoupling the navigation logic from the presentation logic. This separation of concerns allows the views to focus solely on their specific functionalities, while the Navigation Coordinator takes charge of the app's overall navigation flow. It is encharge if build the tab bar (UITabbarController) with the coordinators that were defined in its route, some features are:

<br>
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
      <td><code style="color: blue;">currentPage</code></td>
      <td> Returns the current page selected.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">getCoordinatorSelected()</code></td>
      <td> 
        <ul>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default <code style="color: #ec6b6f;">mainCoordinator</code>,</li>
        </ul>
      </td>
      <td>Returns the coordinator selected that is associated to the selected tab</td>
    </tr>
    <tr>
      <td><code style="color: blue;">setPages(_)</code></td>
      <td> 
        <ul>
          <li><b>_values:</b> <code>[PAGE]?</code>, default <code style="color: #ec6b6f;">mainCoordinator</code>,</li>
          <li><b>completion:</b> <code>(() -> Void)?</code>, default: <code style="color: #ec6b6f;">nil</code></li>
        </ul>
      </td>
      <td>Updates the page set.</td>
    </tr>
    <tr>
      <td><code style="color: blue;">forcePresentation(_)</code></td>
      <td> 
        <ul>
          <li><b>animated:</b> <code>Bool?</code>, default <code style="color: #ec6b6f;">true</code>,</li>
          <li><b>mainCoordinator:</b> <code>Coordinator?</code>, default: <code style="color: #ec6b6f;">mainCoordinator</code></li>
        </ul>
      </td>
      <td>Puts the current coordinator at the top of the coordinator stack, making it the active and visible coordinator. This feature is very useful to start the navigation flow from push notifications, notification center, atypical flows, etc.</td>
    </tr>
  </tbody>
</table>

_____

### Installation 💾

SPM

Open Xcode and your project, click File / Swift Packages / Add package dependency... . In the textfield "Enter package repository URL", write <https://github.com/felilo/ALCoordinator> and press Next twice
_____

## Contributing

Contributions to the ALCoordinator library are welcome! To contribute, simply fork this repository and make your changes in a new branch. When your changes are ready, submit a pull request to this repository for review.

License

The ALCoordinator library is released under the MIT license. See the LICENSE file for more information.

<style>
table th:first-of-type, td:first-of-type {
    width: 20% !important;
}
table th:nth-of-type(2), td:nth-of-type(2) {
    width: 40% !important;
}
table th:nth-of-type(3), td:nth-of-type(3) {
    width: 40% !important;
}


table colgroup col {
  width: auto !important;
}
</style>
