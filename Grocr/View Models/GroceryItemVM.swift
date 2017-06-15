//
//  GroceryItemVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import RxCocoa

protocol GroceryItemVMType:class {
  
  var title:Driver<String>{get}
  var completed:Driver<Bool>{get}
  var imgURL:Driver<URL?>{get}
  var amount:Driver<String?>{get}
  var description:Driver<String?>{get}
  var updateCompleted:PublishSubject<Bool>{get}
  
  var groceryItem:GroceryItem? {get}
  
  func startEditing(title:Observable<String?>, amount:Observable<String?>, description:Observable<String?>, imageUploadEvent:Observable<UIImage>)->Observable<Double>
  func saveEditedData()
  
}

final class GroceryItemVM:GroceryItemVMType {
  
  fileprivate let titleSubj = BehaviorSubject<String>(value: "")
  fileprivate let completedSubj = BehaviorSubject<Bool>(value: false)
  fileprivate let amountSubj = BehaviorSubject<String?>(value: "none")
  fileprivate let descriptionSubj = BehaviorSubject<String?>(value: "No description.")
  fileprivate let imgURLSubj = BehaviorSubject<URL?>(value:nil)
  fileprivate (set) var updateCompleted = PublishSubject<Bool>()

  fileprivate (set) lazy var title:Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var amount:Driver<String?> = self.amountSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var description:Driver<String?> = self.descriptionSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var completed:Driver<Bool> = self.completedSubj.asDriver(onErrorJustReturn: false)
  fileprivate (set) lazy var imgURL:Driver<URL?> = self.imgURLSubj.asDriver(onErrorJustReturn: nil)

  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  
  fileprivate (set) var groceryItem:GroceryItem?
  
  fileprivate var editVM:GroceryItemEditVM?
  
  private let apiManager:APIProtocol
  
  init(_ itemID:String, api:APIProtocol) {

    apiManager = api
    
    apiManager.getGroceryItem(itemID).subscribe(onNext: {[weak self] item in
      
      self?.groceryItem = item
      self?.titleSubj.onNext(item.name)
      self?.amountSubj.onNext(item.amount)
      self?.descriptionSubj.onNext(item.itemDescription)
      self?.completedSubj.onNext(item.completed)
      
      if let strSelf = self {
        let urlExtractor = FileURLExtractor.imageURL(strSelf.groceryItem?.imageID)
        urlExtractor?.bind(to:strSelf.imgURLSubj).disposed(by: strSelf.disposeBag)
      }

    }).disposed(by: disposeBag)
    
    
    updateCompleted.asObservable()
      .subscribe(onNext: {[weak self]  newVal in
        if let item = self?.groceryItem{
          self?.apiManager.updateGroceryItemCompletion(item, completed: newVal)
        }
      }).disposed(by: disposeBag)
  }
  
  
  func startEditing(title:Observable<String?>, amount:Observable<String?>, description:Observable<String?>, imageUploadEvent:Observable<UIImage>)->Observable<Double>
  {
    if let item = groceryItem {
      editVM = GroceryItemEditVM(item: item, title: title, amount: amount, description: description, imageUploadEvent: imageUploadEvent)
      return editVM!.imgUpload
    }
   return Observable.empty()
  }
  
  
  func saveEditedData()
  {
    editVM?.save()
    editVM = nil
  }
  
  
  deinit
  {
    updateCompleted.onCompleted()

  }
}


