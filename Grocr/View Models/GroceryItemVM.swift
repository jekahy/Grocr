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
import FirebaseStorage

enum ImageUploadError:Error {
  
  case failedWithMessage(String)
  case failed
  case cancelled
}


protocol GroceryItemVMType:class {
  
  var title:Driver<String>{get}
  var completed:Driver<Bool>{get}
  var imgURL:Driver<URL?>{get}
  var amount:Driver<String?>{get}
  var description:Driver<String?>{get}
  var updateCompleted:PublishSubject<Bool>{get}
  var itemID:String{get}
  func removeFromDB()
  
  func startEditing(title:Observable<String?>, amount:Observable<String?>, description:Observable<String?>, imageUploadEvent:Observable<UIImage>)->Observable<Double>
  func saveEditedData()
  
}

final class GroceryItemVM:GroceryItemVMType {
  
  
  fileprivate let groceriesRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let itemRef:DatabaseReference
  
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
  
  fileprivate var groceryItem:GroceryItem?
  
  fileprivate var editVM:GroceryItemEditVM?
  
  let itemID: String
  
  
  init(_ groceryItemID:String) {


    itemID = groceryItemID
    itemRef = Database.database().reference(withPath: "grocery-items/\(groceryItemID)")
    
    itemRef.observe(.value, with: {[unowned self] snapshot in
      
      if let item = GroceryItem(snapshot: snapshot){
        self.groceryItem = item
        self.titleSubj.onNext(item.name)
        self.amountSubj.onNext(item.amount)
        self.descriptionSubj.onNext(item.itemDescription)
        self.completedSubj.onNext(item.completed)
        self.groceryItem?.imageURL?.bind(to:self.imgURLSubj).disposed(by: self.disposeBag)
        
      }
    })
    
    updateCompleted.asObservable()
      .subscribe(onNext: {[weak self]  newVal in
        if let item = self?.groceryItem{
          self?.itemRef.child("completed").setValue(newVal)
          self?.groceriesRef.child("\(item.groceryID!)/items").updateChildValues([item.key:newVal])
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
  
  func removeFromDB()
  {
    itemRef.removeValue()
  }
  
  
  deinit {
    itemRef.removeAllObservers()
    updateCompleted.onCompleted()

  }
}


