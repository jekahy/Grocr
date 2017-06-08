//
//  GroceryVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import RxCocoa
import FirebaseDatabase

protocol GroceryVMType {
  
  func addItem(_ name:String)
  var itemVMs:Observable<[GroceryItemVM]> {get}
}


final class GroceryVM: GroceryVMType {
  
  fileprivate let grocRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let itemsRef = Database.database().reference(withPath: "grocery-items")

  fileprivate let groceryID:String!
  fileprivate let itemsVar = Variable<[GroceryItemVM]>([])
  lazy var itemVMs:Observable<[GroceryItemVM]> = self.itemsVar.asObservable()



  init(_ groceryID:String)
  {
    self.groceryID = groceryID
    let refItems = grocRef.child("\(groceryID)/items")
   
    refItems.observe(.childRemoved, with: { snapshot in
      
      let item = GroceryItemVM(snapshot.key)
      if let idxToDelete = self.itemsVar.value.index(where: {$0 == item}){
          self.itemsVar.value.remove(at: idxToDelete)
      }
    })
    
    refItems.observe(.childAdded, with: { snapshot in
      
      let item = GroceryItemVM(snapshot.key)
      self.itemsVar.value.append(item)
    })
    
    
  }
  
  func addItem(_ name: String)
  {
    let groceryItemRef = itemsRef.childByAutoId()
    
    let groceryItem = GroceryItem(name: name,
                                  addedByUser: Auth.auth().currentUser?.email,
                                  groceryID:groceryID,
                                  ref: groceryItemRef)
    
    groceryItemRef.setValue(groceryItem.jsonStr)
    grocRef.child("\(groceryID!)/items").updateChildValues([groceryItem.key : false])
  
  }
  
}
