//
//  Injectable.swift
//  Grocr
//
//  Created by Eugene on 12.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

protocol Injectable {
  
  associatedtype T
  
  func inject(_: T)
  func assertDependencies()
  
}
