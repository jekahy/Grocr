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
  var itemID:String{get}
  func removeFromDB()
}

final class GroceryItemVM: GroceryItemVMType {
  
  
  fileprivate let groceriesRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let itemRef:DatabaseReference
  fileprivate let titleSubj = BehaviorSubject<String>(value: "")
  fileprivate let completedSubj = BehaviorSubject<Bool>(value: false)
  fileprivate (set) lazy var title:Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var completed:Driver<Bool> = self.completedSubj.asDriver(onErrorJustReturn: false)
  fileprivate (set) var updateCompleted = PublishSubject<Bool>()

  fileprivate var groceryItem:GroceryItem?
  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  
  let itemID: String
  
  
  init(_ groceryItemID:String) {


    itemID = groceryItemID
    itemRef = Database.database().reference(withPath: "grocery-items/\(groceryItemID)")
    
    itemRef.observe(.value, with: {[weak self] snapshot in
      
      if let item = GroceryItem(snapshot: snapshot){
        self?.groceryItem = item
        self?.titleSubj.onNext(item.name)
        self?.completedSubj.onNext(item.completed)
      }
    })
    
    updateCompleted.asObservable()
      .subscribe(onNext: {[weak self, weak itemRef]  newVal in
        if let item = self?.groceryItem{
          itemRef?.child("completed").setValue(newVal)
          self?.groceriesRef.child("\(item.groceryID!)/items").updateChildValues([item.key:newVal])
        }
        
      }).disposed(by: disposeBag)
  }
  
  
  func removeFromDB()
  {
    itemRef.removeValue()
  }
  
  
  deinit {
    itemRef.removeAllObservers()
    updateCompleted.onCompleted()
    updateCompleted.dispose()
    disposeBag = nil
  }
}


