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
  func removeGrocery(_ grocery:GroceryVMType)
}

final class GroceryListVM : GroceryListType {

  private let apiManager : APIProtocol.Type
  lazy var groceryVMs: Observable<[GroceryVM]> = self.apiManager.getGroceries().map({$0.map({GroceryVM($0.key, api: APIManager.self)})})
  
  
  init(api:APIProtocol.Type)
  {
    apiManager = api
  }
  
  
  func addGrocery(_ name: String)
  {
    apiManager.addGrocery(name)
  }
  
  func removeGrocery(_ groceryVM:GroceryVMType)
  {
    if let grocery = groceryVM.grocery {
      apiManager.removeGrocery(grocery)
    }
  }
}
