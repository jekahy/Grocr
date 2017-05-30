//
//  FRModel.swift
//  Grocr
//
//  Created by Eugene on 29.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import FirebaseDatabase
import ObjectMapper

protocol FRModel:Mappable {
  
  var ref:DatabaseReference! {get set}
  var key:String! {get set}
  
  var createdAt:Date {get set}
}

extension FRModel
{
  var jsonStr:[String:Any]
  {
    return self.toJSON()
  }
  
  var jsonStrShort:String?
  {
    return "{key:\(self.key)}"
  }

  init?(snapshot: DataSnapshot)
  {
    guard let json = snapshot.value as? [String:Any]else{
      return nil
    }
    self.init(JSON: json)
    
    self.ref = snapshot.ref
    self.key = snapshot.key
  }
  
  
}
