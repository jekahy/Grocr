//
//  Validatable.swift
//  Grocr
//
//  Created by Eugene on 26.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//
import SwiftValidator

protocol Validatable {
  
  func setupValidator()
  var validator:Validator{get}
  
}
