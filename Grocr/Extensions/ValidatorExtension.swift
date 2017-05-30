//
//  ValidatorExtension.swift
//  Grocr
//
//  Created by Eugene on 26.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import SwiftValidator

extension Validator{
  
  func registerField(_ field: ValidatableField, errorLabel:UILabel? = nil, rules:LoginVC.ValidationRules)
  {
    self.registerField(field, rules: rules.rules())
  }
  
}
