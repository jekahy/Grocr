//
//  AlertVCExtension.swift
//  Grocr
//
//  Created by Eugene on 27.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {

  func addAction(_ action: UIAlertAction.DefaultAction)
  {
    self.addAction(action.action)
  }
}
