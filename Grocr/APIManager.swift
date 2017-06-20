//
//  APIManager.swift
//  Grocr
//
//  Created by Eugene on 14.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import FirebaseDatabase

class APIManager : APIProtocol {
  
  static let sharedAPI = APIManager()
  private static let listsRef = FIRDatabaseLocation.lists.reference()
  private static let itemsRef = FIRDatabaseLocation.items.reference()
  
  static func addGrocery(_ name: String)
  {
    let grListRef = APIManager.listsRef.childByAutoId()
    let grList = Grocery(name: name, ref: grListRef)
    grListRef.setValue(grList.jsonStr)
  }
  
  static func getGrocery(_ groceryID:String)->Observable<Grocery>
  {
    return Observable<Grocery>.create({ observer -> Disposable in
      
      let ref = APIManager.listsRef.child(groceryID)
      let h = ref.observe(.value, with: { snapshot in
        if let groc = Grocery(snapshot: snapshot){
          observer.onNext(groc)
        }
      })
      return Disposables.create {
        ref.removeObserver(withHandle: h)
      }
    })
  }
  
  static func removeGrocery(_ grocery: Grocery)
  {
    grocery.ref.removeValue()
  }

  
  static func getGroceries() -> Observable<[Grocery]>
  {
    let groceriesVar = Variable<[Grocery]>([])
    APIManager.listsRef.observe(.childAdded, with: { snapshot in
      
      if let grocery = Grocery(snapshot:snapshot){
        groceriesVar.value.append(grocery)
      }
      
    })
    
    APIManager.listsRef.observe(.childRemoved, with: { snapshot in
      
      if let idxToDelete = groceriesVar.value.index(where: {$0.key == snapshot.key}){
        groceriesVar.value.remove(at: idxToDelete)
      }
    })
    return groceriesVar.asObservable()
  }
  
  
  static func getGroceryItems(_ grocery:Grocery) -> Observable<[GroceryItem]>
  {
    
    return Observable<[GroceryItem]>.create({ observer -> Disposable in
      
      var items = [GroceryItem]()
      
      let groceryItemsRef = grocery.ref.child("items")
      
      let h1 = groceryItemsRef.observe(.childRemoved, with: { snapshot in
        
        if let idxToDelete = items.index(where: {$0.key == snapshot.key}){
          items.remove(at: idxToDelete)
          observer.onNext(items)
        }
      })
      
      let h2 = groceryItemsRef.observe(.childAdded, with: { snapshot in
        
        let itemRef = APIManager.itemsRef.child(snapshot.key)
        itemRef.observeSingleEvent(of:.value, with: { itemSnapshot in
          if let item = GroceryItem(snapshot: itemSnapshot){
            items.append(item)
            observer.onNext(items)
          }
        })
      })
      
      return Disposables.create {
        groceryItemsRef.removeObserver(withHandle: h1)
        groceryItemsRef.removeObserver(withHandle: h2)
      }
    })
  }
  
  static func addGroceryItem(_ name: String, to parentGrocery:Grocery)
  {
    let groceryItemRef = APIManager.itemsRef.childByAutoId()
    
    let groceryItem = GroceryItem(name: name,
                                  addedByUser: Auth.auth().currentUser?.email,
                                  groceryID:parentGrocery.key,
                                  ref: groceryItemRef)
    
    groceryItemRef.setValue(groceryItem.jsonStr)
    parentGrocery.ref.child("items").updateChildValues([groceryItem.key : false])
  }
  
  
  static func getGroceryItem(_ itemID:String)->Observable<GroceryItem>
  {
    return Observable<GroceryItem>.create({ observer -> Disposable in
      
      let ref = APIManager.itemsRef.child(itemID)
      let h = ref.observe(.value, with: { snapshot in
        if let item = GroceryItem(snapshot: snapshot){
          observer.onNext(item)
        }
      })
      return Disposables.create {
        ref.removeObserver(withHandle: h)
      }
    })
  }
  
  
  static func updateGroceryItemCompletion(_ item:GroceryItem,  completed:Bool)
  {
    item.ref.child("completed").setValue(completed)
    APIManager.listsRef.child("\(item.groceryID!)/items").updateChildValues([item.key:completed])
  }

  static func removeItem(_ item: GroceryItem, from parentGrocery:Grocery)
  {
    parentGrocery.ref.child("items").updateChildValues([item.key : NSNull()])
    item.ref.removeValue()
  }
  
  
  static func createImageID(for item:GroceryItem)->String
  {
    let imgItemRef = item.ref.child("imageID")
    return imgItemRef.childByAutoId().key
  }
}
