//
//  FIRDatabaseLocations.swift
//  Grocr
//
//  Created by Eugene on 13.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import FirebaseDatabase

enum FIRDatabaseLocation:String  {
  
  case lists = "grocery-lists"
  case items = "grocery-items"
  
  func reference() -> DatabaseReference
  {
    return Database.database().reference(withPath: self.rawValue)
  }
}
