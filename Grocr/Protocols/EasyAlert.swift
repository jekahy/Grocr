//
//  EasyAlert.swift
//  Grocr
//
//  Created by Eugene on 26.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

protocol EasyAlert {}

extension EasyAlert where Self:UIViewController{
  
  func showAlert(_ title: String?, message: String?, alertActions: [UIAlertAction])
  {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    _ = alertActions.map{alert.addAction($0)}
    self.show(alert, sender: nil)
  }
  
}
