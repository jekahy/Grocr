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
  
  var groceryVMs:Observable<[GroceryListItemVM]>{get}
  func addGrocery(_ name:String)
  func removeGrocery(atIndex index:Int)
}

final class GroceryListVM : GroceryListType {

  
  fileprivate let ref = Database.database().reference(withPath: "grocery-lists")

  fileprivate let groceriesVar = Variable<[GroceryListItemVM]>([])
  lazy var groceryVMs: Observable<[GroceryListItemVM]> = self.groceriesVar.asObservable()
  
  init()
  {
    
    ref.observe(.childAdded, with: { [unowned self] snapshot in
      
      if let grocery = Grocery(snapshot:snapshot){
        let groceryListItem = GroceryListItemVM(grocery: grocery)
        self.groceriesVar.value.append(groceryListItem)
      }
      
    })
    
    ref.observe(.childRemoved, with: { [unowned self] snapshot in
      
      if let grocery = Grocery(snapshot:snapshot){
        let groceryListItem = GroceryListItemVM(grocery: grocery)
        
        if let idxToDelete = self.groceriesVar.value.index(where: {$0 == groceryListItem}){
          self.groceriesVar.value.remove(at: idxToDelete)
        }
      }
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
    groceriesVar.value[index].removeFromDB()
  }

}
