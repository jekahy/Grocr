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

protocol GroceryVMType:class {
  
  var title: Driver<String>{get}
  var count: Driver<String>{get}
  var groceryID:String {get}
  func removeFromDB()

  func addItem(_ name:String)
  func removeItem(atIndex index:Int)
  var itemVMs:Observable<[GroceryItemVM]> {get}
}


final class GroceryVM: GroceryVMType {
  
  fileprivate let listsRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let itemsRef = Database.database().reference(withPath: "grocery-items")

  fileprivate let itemsVar = Variable<[GroceryItemVM]>([])
  lazy var itemVMs:Observable<[GroceryItemVM]> = self.itemsVar.asObservable()

  fileprivate (set) lazy var title: Driver<String> = self.titleVar.asDriver()
  fileprivate (set) lazy var count: Driver<String> = self.countVar.asDriver()
  
  fileprivate let titleVar = Variable<String>("")
  fileprivate let countVar = Variable<String>("")


  fileprivate var grocery:Grocery!
  
  var groceryID: String {
    return grocery.key
  }
  
  init(_ groceryID:String)
  {
    
    let refItems = listsRef.child("\(groceryID)/items")
    let refGrocrecy = listsRef.child("\(groceryID)")
    
    refGrocrecy.observe(.value, with: { snapshot in
      if let groc = Grocery(snapshot: snapshot){
        self.grocery = groc
        self.titleVar.value = groc.name
        let completedItems = groc.items.filter{$0.value}.count
        self.countVar.value = groc.items.count > 0 ? "\(completedItems)/\(groc.items.count)" : ""
      }
    })
    
   
    refItems.observe(.childRemoved, with: { snapshot in
      
      if let idxToDelete = self.itemsVar.value.index(where: {$0.itemID == snapshot.key}){
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
    listsRef.child("\(groceryID)/items").updateChildValues([groceryItem.key : false])
  
  }
  
  func removeFromDB()
  {
    var itemsToRemove = [String:AnyObject]()
    grocery.items.keys.forEach{itemsToRemove[$0]=NSNull()}
    itemsRef.updateChildValues(itemsToRemove)
    grocery.ref.removeAllObservers()
    grocery.ref.removeValue()

  }

  
  func removeItem(atIndex index:Int)
  {
    let itemVM = itemsVar.value[index]
    listsRef.child("\(groceryID)/items").updateChildValues([itemVM.itemID : NSNull()])
    itemVM.removeFromDB()
  }
  
}
