//
//  FIRStorageLocations.swift
//  Grocr
//
//  Created by Eugene on 13.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import FirebaseStorage

enum FIRStorageLocations:String {
  
  case images = "grocery-items-images"
  
  func reference() -> StorageReference
  {
    return Storage.storage().reference().child(self.rawValue)
  }
  
}
