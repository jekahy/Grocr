//
//  GRList.swift
//  Grocr
//
//  Created by Eugene on 29.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import FirebaseDatabase
import ObjectMapper

struct Grocery:FRModel {
  
  var ref: DatabaseReference!
  var key: String!
  
  var name = ""
  var createdAt = Date()
  var items = [String:Bool]()
		
  init?(map: Map) {}
  
  init(name:String, ref:DatabaseReference)
  {
    self.name = name
    self.ref = ref
    self.key = ref.key
    self.createdAt = Date()
  }
  
  mutating func mapping(map: Map)
  {
    name 	<- map["name"]
    createdAt	<- (map["createdAt"], DateTransform())
    items <- map["items"]
  }
}
