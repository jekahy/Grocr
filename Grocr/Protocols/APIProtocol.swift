//
//  APIProtocol.swift
//  Grocr
//
//  Created by Eugene on 15.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift

protocol APIProtocol {
  
  static func getGrocery(_ groceryID:String)->Observable<Grocery>
  static func getGroceries() -> Observable<[Grocery]>
  static func addGrocery(_ name: String)
  static func removeGrocery(_ grocery: Grocery)
  
  static func getGroceryItem(_ itemID:String)->Observable<GroceryItem>
  static func getGroceryItems(_ grocery:Grocery) -> Observable<[GroceryItem]>
  static func addGroceryItem(_ name: String, to:Grocery)
  static func removeItem(_ item: GroceryItem, from:Grocery)
  static func updateGroceryItemCompletion(_ item:GroceryItem,  completed:Bool)
  
  static func createImageID(for item:GroceryItem)->String
  
}
