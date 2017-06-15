//
//  GroceryVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import RxCocoa

protocol GroceryVMType:class {
  
  var title: Driver<String>{get}
  var count: Driver<String>{get}
  var grocery:Grocery?{get}
  var itemVMs:Observable<[GroceryItemVMType]> {get}

  func addItem(_ name:String)
  func removeItem(_ itemVM:GroceryItemVMType)
}


final class GroceryVM: GroceryVMType {
  
  lazy var itemVMs:Observable<[GroceryItemVMType]> = {
    guard let grocery = self.grocery else{
      return Observable<[GroceryItemVMType]>.empty()
    }
    return self.apiManager.getGroceryItems(grocery).map({$0.map({GroceryItemVM($0.key, api: APIManager())})})
  }()


  private (set) lazy var title: Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  private (set) lazy var count: Driver<String> = self.countSubj.asDriver(onErrorJustReturn: "")
  
  private let titleSubj = BehaviorSubject<String>(value: "")
  private let countSubj = BehaviorSubject<String>(value: "")

  private (set) var grocery:Grocery?
  private let apiManager : APIProtocol
  private let disposeBag = DisposeBag()
  
  
  init(_ groceryID:String, api:APIProtocol)
  {
    apiManager = api
    
    apiManager.getGrocery(groceryID).subscribe(onNext: {[weak self] grocery in
      
      self?.grocery = grocery
      self?.titleSubj.onNext(grocery.name)
      
      let completedItems = grocery.items.filter{$0.value}.count
      let newCompletionCount = grocery.items.count > 0 ? "\(completedItems)/\(grocery.items.count)" : ""
      self?.countSubj.onNext(newCompletionCount)
      
    }).disposed(by: disposeBag)
  }
  
  func addItem(_ name: String)
  {
    if let grocery = self.grocery {
      apiManager.addGroceryItem(name, to: grocery)
    }
  }
  
  func removeItem(_ itemVM:GroceryItemVMType)
  {
    if let grocery = self.grocery, let item = itemVM.groceryItem {
      apiManager.removeItem(item, from: grocery)
    }
  }
  
  deinit
  {
    titleSubj.onCompleted()
    countSubj.onCompleted()
  }
}
