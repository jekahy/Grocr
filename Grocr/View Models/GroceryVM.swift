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

  fileprivate let disposeBag = DisposeBag()

  init(_ groceryID:String)
  {
    
    self.groceryID = groceryID
    let refItems = grocRef.child("\(groceryID)/items")
    
    refItems.observe(.value, with:{ snapshot in

        self.itemsVar.value = snapshot.children.allObjects.map{ $0 as! DataSnapshot}
          .flatMap{GroceryItemVM($0.key)}

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
    grocRef.child("\(groceryID!)/items").updateChildValues([groceryItem.key : true])
  
  }
  
}


//extension GroceryVM:VariableProvidable {
//  
//  var variable: Variable<GroceryVM> {
//    return Variable(self)
//  }
//}
