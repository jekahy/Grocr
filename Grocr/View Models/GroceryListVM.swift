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

  
  fileprivate let ref = FIRDatabaseLocation.lists.reference()

  fileprivate let groceriesVar = Variable<[GroceryVM]>([])
  lazy var groceryVMs: Observable<[GroceryVM]> = self.groceriesVar.asObservable()
  
  init()
  {
    ref.observe(.childAdded, with: { [weak self] snapshot in
      
      if let grocery = Grocery(snapshot:snapshot){
        
        self?.groceriesVar.value.append(GroceryVM(grocery.key))
      }
      
    })
    
    ref.observe(.childRemoved, with: { [weak self] snapshot in
      
        if let idxToDelete = self?.groceriesVar.value.index(where: {$0.groceryID == snapshot.key}){
          self?.groceriesVar.value.remove(at: idxToDelete)
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

  deinit {
    
    ref.removeAllObservers()
  }
}
