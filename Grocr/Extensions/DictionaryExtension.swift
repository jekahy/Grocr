//
//  DictionaryExtension.swift
//  Grocr
//
//  Created by Eugene on 02.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//


extension Dictionary {
  func mapDictionary(transform: (Key, Value) -> (Key, Value)?) -> Dictionary<Key, Value> {
    var dict = [Key: Value]()
    for key in keys {
      guard let value = self[key], let keyValue = transform(key, value) else {
        continue
      }
      
      dict[keyValue.0] = keyValue.1
    }
    return dict
  }
}
