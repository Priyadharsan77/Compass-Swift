//
//  MapViewControllerDelegate.swift
//  compass
//
//  Created by Dhars on 23/04/2017.
//  Copyright © 2017 Dhars. All rights reserved.
//

import Foundation
import CoreLocation

protocol MapViewControllerDelegate {
  func update(location: CLLocation)
}
