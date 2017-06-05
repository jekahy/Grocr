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
  
  fileprivate let titleVar = Variable("")
  fileprivate let completedVar = Variable(false)
  fileprivate (set) lazy var title:Driver<String> = self.titleVar.asDriver()
  fileprivate (set) lazy var completed:Driver<Bool> = self.completedVar.asDriver()
  fileprivate (set) var updateCompleted = PublishSubject<Bool>()

  fileprivate let disposeBag = DisposeBag()
 
  
  init(_ groceryItemID:String) {

    
    let ref = Database.database().reference(withPath: "grocery-items/\(groceryItemID)")
    ref.observe(.value, with: {[weak self] snapshot in
      
      if let item = GroceryItem(snapshot: snapshot){
        self?.completedVar.value = item.completed
        self?.titleVar.value = item.name
      }
    })
    
    updateCompleted.asObservable()
      .subscribe(onNext: { newVal in
        ref.child("completed").setValue(newVal)
        
      }).disposed(by: disposeBag)
  }
}
