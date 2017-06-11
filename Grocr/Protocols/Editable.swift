//
//  Editable.swift
//  Grocr
//
//  Created by Eugene on 10.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift

protocol Editable{
  
  func enableEditMode()
  func disableEditMode()
}

extension Editable {
  var editBGColor:UIColor?{
    return UIColor.lightGray
  }
}
