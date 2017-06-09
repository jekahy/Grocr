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
  
  fileprivate static let groceriesPath = "grocery-lists"
  fileprivate static let itemsPath = "grocery-items"
  fileprivate let groceryRef:DatabaseReference
  fileprivate let groceryItemsRef:DatabaseReference
  fileprivate let itemsRef = Database.database().reference(withPath: itemsPath)

  fileprivate let itemsVar = Variable<[GroceryItemVM]>([])
  lazy var itemVMs:Observable<[GroceryItemVM]> = self.itemsVar.asObservable()

  fileprivate (set) lazy var title: Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var count: Driver<String> = self.countSubj.asDriver(onErrorJustReturn: "")
  
  fileprivate let titleSubj = BehaviorSubject<String>(value: "")
  fileprivate let countSubj = BehaviorSubject<String>(value: "")


  fileprivate var grocery:Grocery!
  
  var groceryID: String {
    return grocery.key
  }
  
  init(_ groceryID:String)
  {
    groceryRef = Database.database().reference(withPath: GroceryVM.groceriesPath).child("\(groceryID)")
    groceryItemsRef = groceryRef.child("items")
    
    groceryRef.observe(.value, with: {[weak self]  snapshot in
      
      if let groc = Grocery(snapshot: snapshot){
        self?.grocery = groc
        self?.titleSubj.onNext(groc.name)
        
        let completedItems = groc.items.filter{$0.value}.count
        let newCompletionCount = groc.items.count > 0 ? "\(completedItems)/\(groc.items.count)" : ""
        self?.countSubj.onNext(newCompletionCount)
      }
    })

   
    groceryItemsRef.observe(.childRemoved, with: { [weak self] snapshot in
      
      if let idxToDelete = self?.itemsVar.value.index(where: {$0.itemID == snapshot.key}){
          self?.itemsVar.value.remove(at: idxToDelete)
      }
    })
    
    groceryItemsRef.observe(.childAdded, with: { [weak self] snapshot in
      
      let item = GroceryItemVM(snapshot.key)
      self?.itemsVar.value.append(item)
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
    groceryItemsRef.updateChildValues([groceryItem.key : false])
  
  }
  
  func removeFromDB()
  {
    var itemsToRemove = [String:AnyObject]()
    grocery.items.keys.forEach{itemsToRemove[$0]=NSNull()}
    itemsRef.updateChildValues(itemsToRemove)
    groceryRef.removeAllObservers()
    groceryRef.removeValue()

  }

  
  func removeItem(atIndex index:Int)
  {
    let itemVM = itemsVar.value[index]
    groceryItemsRef.updateChildValues([itemVM.itemID : NSNull()])
    itemVM.removeFromDB()
  }
  
  deinit
  {
    titleSubj.onCompleted()
    countSubj.onCompleted()
    titleSubj.dispose()
    countSubj.dispose()
    groceryRef.removeAllObservers()
    groceryItemsRef.removeAllObservers()
  }
}
