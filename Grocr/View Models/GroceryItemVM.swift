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


protocol GroceryItemVMType:AnyObject {
  var title:Driver<String>{get}
  var completed:Driver<Bool>{get}
  var updateCompleted:PublishSubject<Bool>{get}
}

final class GroceryItemVM: GroceryItemVMType, Equatable {
  
  
  fileprivate let groceriesRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let titleSubj = PublishSubject<String>()
  fileprivate let completedSubj = PublishSubject<Bool>()
  fileprivate (set) lazy var title:Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var completed:Driver<Bool> = self.completedSubj.asDriver(onErrorJustReturn: false)
  fileprivate (set) var updateCompleted = PublishSubject<Bool>()

  fileprivate var groceryItem:GroceryItem?
  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  fileprivate let groceryItemID:String
  
  init(_ groceryItemID:String) {

    self.groceryItemID = groceryItemID
    let ref = Database.database().reference(withPath: "grocery-items/\(groceryItemID)")
    
    ref.observe(.value, with: {[weak self] snapshot in
      
      if let item = GroceryItem(snapshot: snapshot){
        self?.groceryItem = item
        self?.titleSubj.onNext(item.name)
        self?.completedSubj.onNext(item.completed)
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
  
  deinit {
    
    updateCompleted.onCompleted()
    disposeBag = nil
  }
  
  
  public static func ==(lhs: GroceryItemVM, rhs: GroceryItemVM) -> Bool
  {
    return lhs.groceryItemID == rhs.groceryItemID
  }
}


