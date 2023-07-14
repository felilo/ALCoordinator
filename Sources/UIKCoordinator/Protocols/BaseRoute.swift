//
//  File.swift
//  
//
//  Created by Andres Lozano on 13/07/23.
//

import UIKit

public protocol NavigationRoute {
  
  associatedtype T
  
  var transition: NavigationTransitionStyle { get }
  
  /// Creates and returns a view of assosiated type
  ///
  func view() -> T
}


public enum NavigationTransitionStyle {
  case push
  case present
  case presentFullscreen
  case custom(style: UIModalPresentationStyle)
}
