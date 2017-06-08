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
  
  var groceryVMs:Observable<[GroceryVM]>{get}
  func addGrocery(_ name:String)
  func removeGrocery(atIndex index:Int)
}

final class GroceryListVM : GroceryListType {

  
  fileprivate let ref = Database.database().reference(withPath: "grocery-lists")

  fileprivate let groceriesVar = Variable<[GroceryVM]>([])
  lazy var groceryVMs: Observable<[GroceryVM]> = self.groceriesVar.asObservable()
  
  init()
  {
    
    ref.observe(.childAdded, with: { [unowned self] snapshot in
      
      if let grocery = Grocery(snapshot:snapshot){
        let groceryVM = GroceryVM(grocery.key)
        self.groceriesVar.value.append(groceryVM)
      }
      
    })
    
    ref.observe(.childRemoved, with: { [unowned self] snapshot in
      
      if let grocery = Grocery(snapshot:snapshot){
        
        if let idxToDelete = self.groceriesVar.value.index(where: {$0.groceryID == grocery.key}){
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
