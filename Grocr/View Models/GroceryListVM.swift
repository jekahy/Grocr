//
//  GroceryListVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import FirebaseDatabase

protocol GroceryListType {
  
  var groceryVMs:Observable<[GroceryListItemVMType]>{get}
  func addGrocery(_ name:String)
  func removeGrocery(atIndex index:Int)
}

final class GroceryListVM : GroceryListType {

  
  fileprivate let ref = Database.database().reference(withPath: "grocery-lists")

  fileprivate let groceriesVariable = Variable<[GroceryListItemVMType]>([])
  lazy var groceryVMs: Observable<[GroceryListItemVMType]> = self.groceriesVariable.asObservable()
  
  init()
  {
    ref.observe(.value, with: {[weak self] snapshot in
    
      let ls = snapshot.children.flatMap({Grocery(snapshot: $0 as! DataSnapshot)}).map{GroceryListItemVM(grocery: $0)}
      self?.groceriesVariable.value = ls
    })
  }
  
  
  func addGrocery(_ name: String)
  {
    
    let grListRef = ref.childByAutoId()
    let grList = Grocery(name: name, ref: grListRef)
    grListRef.setValue(grList.jsonStr)

  }
  
  func removeGrocery(atIndex index:Int)
  {
    let grocVM = groceriesVariable.value[index]
    grocVM.removeFromDB()
  }
}
