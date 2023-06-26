# ALCoodinator

This repository contains a library implementing the Coordinator pattern, which is a design pattern used in iOS app development to manage app navigation flows. The library provides a set of classes and protocols that can be used to implement the Coordinator pattern in an iOS app. It works either UIKit or SwiftUI apps

Its core navigation has created with UINavigationController (UIKit) with the aim to get profit about navigation stack.

### Getting Started

To use the Coordinator pattern library in your iOS project, you'll need to add the library files to your project and set up a Coordinator object. Here are the basic steps:

<br>

### Create a Coordinator

```swift
    enum OnboardingRouter: NavigationRouter {

      case firstStep(viewModel: FirstStepViewModel)
      case secondStep(viewModel: SecondStepViewModel)
      case info(message: String)

      // MARK: NavigationRouter
      var transition: NavigationTranisitionStyle {
        switch self {
          case .firstStep, secondStep:
            return .push
          case .info:
            return .present
        }
      }

      func view() -> any View {
        switch self {
          case .firstStep(let vm):
            return FirstStepView(viewModel: vm)
          case .secondStep(let vm):
            return SecondStepView().environmentObject(vm)
          case .info(let message):
            return InfoView(message: message)
        }
      }
    }
```
        
```swift
    class OnboardingCoordinator: CoordinatorSUI<OnboardingRouter> {

      override func start(animated: Bool) {
        show(.firstStep(viewModel: FirstStepViewModel(coordinator: self)))
        parent.startChildCoordinator(self, animated: animated)
      }

      func showStep2() {
        show(.secondStep(viewModel: SecondStepViewModel(coordinator: self)))
      }
      
      func presentInfo(message: String) {
        show(.info(message: message))
      }

      func showLoginCoordinator() {
        let coordinator = LoginCoordinator()
        coordinator.start()
      }
    }
```
    
<br>    


### Create a TabbarCoordinator


1. Create a router

    ```swift
    enum HomeRouter: CaseIterable, TabbarPage {

      case marketplace
      case settings

      // MARK: NavigationRouter

      func coordinator(parent: Coordinator) -> Coordinator {
        switch self {
          case .settings:
            return SettingCoordinator(parent: parent)
          case .marketplace:
            return MarketplaceCoordinator(parent: parent)
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
    }
    ```
<br>

2. Create a TabbarCoordinator

  * Default tabbar build with UIKIT (It also works with SwiftUI)
    ```swift
    class HomeCoordinator: TabbarCoordinator<HomeRouter> {
    
      public init(parent: Coordinator) {
        let pages: [Router] = [.marketplace, .settings]
        super.init(parent: parent,pages: pages)
      }
    }
    ```

  * Custom view (SwiftUI)

    ```swift
    class HomeCoordinator: TabbarCoordinator<HomeRouter> {
    
      public init(parent: Coordinator) {
        let pages: [Router] = [.marketplace, .settings]
        let view = HomeTabbarView(pages: pages)
        
        super.init(
            parent: parent, 
            customView: view,
            pages: pages
        )
        
        view.$currentPage
          .sink { [weak self] page in
            self?.currentPage = page
          }.store(in: &cancelables)
      }
    }
    ```

<br>


### Create MainCoordinator: 

```swift
    class MainCoordinator: BaseCoordinator {
      
      init() {
        super.init(parent: nil)
      }
      
      override func start(animated: Bool = false) {
        let coordinator = OnboardingCoordinator(parent: self)
        coordinator.start(animated: animated)
      }
    }
```
<br>


### Setup project


<br>

1. Create a SceneDelegate class if your app supports scenes:

```swift
    import UIKit
    import ALCoordinator
    
    class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
        var window: UIWindow?
        var mainCoordinator: Coordinator
    
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            window = UIWindow(windowScene: windowScene)
            window?.makeKeyAndVisible()
            setupCoordinator(window: window, animated: true)
        }
        
        private func setupCoordinator(window: UIWindow?, animated: Bool = false) {
          mainCoordinator = .init()
          window?.rootViewController = mainCoordinator.root
          mainCoordinator?.start(animated: animated)
          BaseCoordinator.mainCoordinator = mainCoordinator
        }
    }
```
<br>

2. In your app's AppDelegate file, set the SceneDelegate class as the windowScene delegate:


```swift
@main
    class AppDelegate: UIResponder, UIApplicationDelegate {
    
        var window: UIWindow?
    
        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    
        func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
        // Add this method
        func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }
            let sceneDelegate = SceneDelegate()
            sceneDelegate.scene(windowScene, willConnectTo: session, options: connectionOptions)
        }
    }
```

<br>
<br>


#### You can find an example here https://github.com/felilo/TestCoordinatorLibrary


### Actions:
Actions you can perform from the coordinator depends on the kind of coordinator used. For instance, using a BaseCoordinator, CoordinatorSUI or Coordinator some of the functions you can perform are:

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

Open Xcode and your project, click File / Swift Packages / Add package dependency... . In the textfield "Enter package repository URL", write https://github.com/felilo/ALCoordinator and press Next twice


## Contributing

Contributions to the ALCoordinator library are welcome! To contribute, simply fork this repository and make your changes in a new branch. When your changes are ready, submit a pull request to this repository for review.

License

The ALCoordinator library is released under the MIT license. See the LICENSE file for more information.
