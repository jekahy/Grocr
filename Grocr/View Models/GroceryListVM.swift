//
//  GroceryListVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift

protocol GroceryListType {
  
  var groceryVMs:Observable<[GroceryVM]>{get}
  func addGrocery(_ name:String)
  func removeGrocery(atIndex index:Int)
}

final class GroceryListVM : GroceryListType {

  private let apiManager : APIProtocol
  lazy var groceryVMs: Observable<[GroceryVM]> = self.apiManager.getGroceries().map({$0.map({GroceryVM($0, api: APIManager())})})
  
  
  init(api:APIProtocol)
  {
    apiManager = api
  }
  
  
  func addGrocery(_ name: String)
  {
    apiManager.addGrocery(name)
//    let grListRef = ref.childByAutoId()
//    let grList = Grocery(name: name, ref: grListRef)
//    grListRef.setValue(grList.jsonStr)

  }
  
  func removeGrocery(atIndex index:Int)
  {
//    if let grocery = groceriesVar.value[index].grocery {
//      apiManager.removeGrocery(grocery)
//    }
//    groceriesVar.value[index].removeFromDB()
    
    
  }
}
