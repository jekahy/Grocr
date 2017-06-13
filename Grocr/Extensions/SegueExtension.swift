//
//  SegueExtension.swift
//  Grocr
//
//  Created by Eugene on 13.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import Perform

extension Segue {
  
  static var showGroceryVC: Segue<GroceryVC> {
    return .init(identifier: "toGoceryVC")
  }
  
  static var showGroceryItemVC: Segue<GroceryItemVC> {
    return .init(identifier: "toGroceryItemVC")
  }
  
  static var showGroceryListVC: Segue<GroceryListVC> {
    return .init(identifier: "toGroceryList")
  }
  

}
