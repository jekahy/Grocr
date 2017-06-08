//
//  ViewModelAvailable.swift
//  Grocr
//
//  Created by Eugene on 07.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

protocol ViewModelAvailable:class {
  
  associatedtype VM:Any
  
  var viewModel:VM?{get set}
}
