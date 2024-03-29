//
//  File.swift
//  
//
//  Created by Andres Lozano on 13/07/23.
//

import Foundation

public protocol NavigationRoute {
  
  associatedtype T
  
  var transition: NavigationTransitionStyle { get }
  
  /// Creates and returns a view of assosiated type
  ///
  func view() -> T
}


public enum NavigationTransitionStyle {
  case push
  case modal
  case modalFullscreen
  case custom(style: PresentationStyle)
}
