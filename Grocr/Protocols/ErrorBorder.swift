//
//  ErrorBorder.swift
//  The app
//
//  Created by Eugene on 26.05.17.
//  Copyright © 2017 Eugenious. All rights reserved.
//

import Foundation
import UIKit

protocol ErrorBorder {}

extension ErrorBorder where Self:UIView{
  
  func highlightError()
  {
    self.layer.borderColor = UIColor.red.cgColor
    self.layer.borderWidth = 2.0
  }
  
  func removeErrorHighlight()
  {
    self.layer.borderWidth = 0
  }
  
}
