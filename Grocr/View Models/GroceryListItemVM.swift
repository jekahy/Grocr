//
//  GroceryListItemVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import RxCocoa
import FirebaseDatabase

protocol GroceryListItemVMType {
  
  var title: Driver<String>{get}
  var count: Driver<String>{get}
  var groceryID:String {get}

}

final class GroceryListItemVM: GroceryListItemVMType {
  
  fileprivate (set) lazy var title: Driver<String> = self.titleVar.asDriver()
  fileprivate (set) lazy var count: Driver<String> = self.countVar.asDriver()
  
  fileprivate let titleVar = Variable<String>("")
  fileprivate let countVar = Variable<String>("")
  
  fileprivate let disposeBag = DisposeBag()
  fileprivate var grocery:Grocery
  
  var groceryID: String {
    return grocery.key
  }
  
  init(grocery:Grocery) {
    
    self.grocery = grocery
    
    grocery.ref.observe(.value, with: {[weak self] snapshot in
      if let groc = Grocery(snapshot: snapshot){
        self?.titleVar.value = groc.name
        let completedItems = groc.items.filter{$0.value}.count
        self?.countVar.value = "\(completedItems)"
      }
      
    })
  }
}
