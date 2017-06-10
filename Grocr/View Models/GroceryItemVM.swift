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
}


protocol GroceryItemVMType:AnyObject {
  var title:Driver<String>{get}
  var completed:Driver<Bool>{get}
  var imgUpload:Observable<Double>{get}
  var imgURL:Driver<URL?>{get}
  var updateCompleted:PublishSubject<Bool>{get}
  var itemID:String{get}
  func removeFromDB()
  func uploadImage(_ image:UIImage)
  func cancelUpload()

}

final class GroceryItemVM: GroceryItemVMType {
  
  
  fileprivate let groceriesRef = Database.database().reference(withPath: "grocery-lists")
  fileprivate let storageRef = Storage.storage().reference().child("grocery-items-images")
  fileprivate let itemRef:DatabaseReference
  
  fileprivate let titleSubj = BehaviorSubject<String>(value: "")
  fileprivate let completedSubj = BehaviorSubject<Bool>(value: false)
  fileprivate let imgURLSubj = BehaviorSubject<URL?>(value:nil)
  fileprivate (set) var updateCompleted = PublishSubject<Bool>()
  fileprivate let imgUploadSubj = BehaviorSubject<Double>(value:0)

  fileprivate (set) lazy var title:Driver<String> = self.titleSubj.asDriver(onErrorJustReturn: "")
  fileprivate (set) lazy var completed:Driver<Bool> = self.completedSubj.asDriver(onErrorJustReturn: false)
  fileprivate (set) lazy var imgURL:Driver<URL?> = self.imgURLSubj.asDriver(onErrorJustReturn: nil)
  fileprivate (set) lazy var imgUpload:Observable<Double> = self.imgUploadSubj.asObservable()

  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  
  fileprivate var groceryItem:GroceryItem?
  
  let itemID: String
  
  fileprivate var uploadTask:StorageUploadTask?{
    didSet{
      
      uploadTask?.observe(.progress) {[unowned self] snapshot in
        if let progress = snapshot.progress?.fractionCompleted {
          self.imgUploadSubj.onNext(progress)
        }
      }
      
      uploadTask?.observe(.failure){[unowned self] snapshot in
        
        self.imgUploadSubj.onError(ImageUploadError.failed)
        
      }
      uploadTask?.observe(.success, handler: { [weak self] snapshot in
        self?.imgUploadSubj.onCompleted()
      })
    }
  }
  
  init(_ groceryItemID:String) {


    itemID = groceryItemID
    itemRef = Database.database().reference(withPath: "grocery-items/\(groceryItemID)")
    
    itemRef.observe(.value, with: {[weak self] snapshot in
      
      if let item = GroceryItem(snapshot: snapshot){
        self?.groceryItem = item
        self?.titleSubj.onNext(item.name)
        self?.completedSubj.onNext(item.completed)
        self?.imgURLSubj.onNext(item.imageURL)
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
  
  
  func removeFromDB()
  {
    itemRef.removeValue()
  }
  
  
  func uploadImage(_ image:UIImage)
  {
    let imgItemRef = itemRef.child("imageID")
    
    let imgID = imgItemRef.childByAutoId().key
    let imgStoreRef = storageRef.child(imgID + ".png")
    
    guard let png = UIImagePNGRepresentation(image) else{
      return
    }
    uploadTask = imgStoreRef.putData(png, metadata: nil) {[weak self] (metadata, error) in
      guard let metadata = metadata else {
        return
      }
      if let downloadURL = metadata.downloadURL(){
        
        imgItemRef.setValue(downloadURL.absoluteString)
      }
      if let error = error {
        self?.imgUploadSubj.onError(error)
      }else{
        self?.imgUploadSubj.onCompleted()
      }
    }
  }
  
  func cancelUpload()
  {
    uploadTask?.cancel()
  }
  
  
  deinit {
    itemRef.removeAllObservers()
    updateCompleted.onCompleted()

  }
}


