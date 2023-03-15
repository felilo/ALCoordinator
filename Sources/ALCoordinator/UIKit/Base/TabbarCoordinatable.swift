//
//  File.swift
//  
//
//  Created by Andres Lozano on 15/03/23.
//

import UIKit


public protocol BaseTabbarCoordinator {
  
  associatedtype PAGE
  
  var tabController: UITabBarController! { get set }
  var currentPage: PAGE? { get set }
  
  
  func getCoordinatorSelected() -> Coordinator
}


public typealias TabbarCoordinatable = BaseCoordinator & BaseTabbarCoordinator
