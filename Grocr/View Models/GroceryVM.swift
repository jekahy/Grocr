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
  var grocery:Grocery!{get}
  func removeFromDB()

  func addItem(_ name:String)
  func removeItem(atIndex index:Int)
  var itemVMs:Observable<[GroceryItemVMType]> {get}
}


final class GroceryVM: GroceryVMType {
  
  lazy var itemVMs:Observable<[GroceryItemVMType]> = self.apiManager.getGroceryItems(self.grocery).map({$0.map({GroceryItemVM($0)})})


  fileprivate (set) lazy var title: Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var count: Driver<String> = self.countSubj.asDriver(onErrorJustReturn: "")
  
  fileprivate let titleSubj = BehaviorSubject<String>(value: "")
  fileprivate let countSubj = BehaviorSubject<String>(value: "")


  fileprivate (set) var grocery:Grocery!
  private let apiManager : APIProtocol
  private let disposeBag = DisposeBag()
  
  var groceryID: String {
    return grocery.key
  }
  
  init(_ grocery:Grocery, api:APIProtocol)
  {
    apiManager = api
    self.grocery = grocery
    
    self.grocery.ref.observe(.value, with: {[weak self]  snapshot in
      
      if let groc = Grocery(snapshot: snapshot){
        self?.grocery = groc
        self?.titleSubj.onNext(groc.name)
        
        let completedItems = groc.items.filter{$0.value}.count
        let newCompletionCount = groc.items.count > 0 ? "\(completedItems)/\(groc.items.count)" : ""
        self?.countSubj.onNext(newCompletionCount)
      }
    })

  }
  
  func addItem(_ name: String)
  {
    apiManager.addGroceryItem(name, to: grocery)
  }
  
  func removeFromDB()
  {
    
//    var itemsToRemove = [String:AnyObject]()
//    grocery.items.keys.forEach{itemsToRemove[$0]=NSNull()}
//    itemsRef.updateChildValues(itemsToRemove)
//    groceryRef.removeAllObservers()
//    groceryRef.removeValue()

  }

  
  func removeItem(atIndex index:Int)
  {
//    let itemVM = itemsVar.value[index]
//    groceryItemsRef.updateChildValues([itemVM.itemID : NSNull()])
//    itemVM.removeFromDB()
  }
  
  deinit
  {
    titleSubj.onCompleted()
    countSubj.onCompleted()
    titleSubj.dispose()
    countSubj.dispose()

  }
}
