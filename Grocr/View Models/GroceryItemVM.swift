//
//  GroceryItemVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import RxCocoa
import FirebaseDatabase


protocol GroceryItemVMType {
  var title:Driver<String>{get}
  var completed:Driver<Bool>{get}
  var updateCompleted:PublishSubject<Bool>{get}
}

final class GroceryItemVM: GroceryItemVMType {
  
  
  fileprivate let groceriesRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let titleVar = Variable("")
  fileprivate let completedVar = Variable(false)
  fileprivate (set) lazy var title:Driver<String> = self.titleVar.asDriver()
  fileprivate (set) lazy var completed:Driver<Bool> = self.completedVar.asDriver()
  fileprivate (set) var updateCompleted = PublishSubject<Bool>()

  fileprivate var groceryItem:GroceryItem?
  fileprivate let disposeBag = DisposeBag()
 
  
  init(_ groceryItemID:String) {

    
    let ref = Database.database().reference(withPath: "grocery-items/\(groceryItemID)")
    
    ref.observe(.value, with: {[weak self] snapshot in
      
      if let item = GroceryItem(snapshot: snapshot){
        self?.groceryItem = item
        self?.completedVar.value = item.completed
        self?.titleVar.value = item.name
      }
    })
    
    updateCompleted.asObservable()
      .subscribe(onNext: {[weak self]  newVal in
        if let item = self?.groceryItem{
          ref.child("completed").setValue(newVal)
          self?.groceriesRef.child("\(item.groceryID!)/items").updateChildValues([item.key:newVal])
        }
        
      }).disposed(by: disposeBag)
  }
}

//extension GroceryItemVM:VariableProvidable {
//  
//  var variable: Variable<GroceryItemVM> {
//    return Variable(self)
//  }
//}
