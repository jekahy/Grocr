//
//  GroceryItemEditVM.swift
//  Grocr
//
//  Created by Eugene on 10.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift
import FirebaseStorage

protocol GroceryItemEditVMType:class {
}

final class GroceryItemEditVM{
  
  fileprivate let storageRef = Storage.storage().reference().child("grocery-items-images")

  fileprivate let disposeBag = DisposeBag()
  fileprivate var item:GroceryItem
  fileprivate lazy var title = AnyObserver<String?>.init { event in
    if case .next(let str) = event, let newTitle = str {
      self.item.name = newTitle
    }
  }
  fileprivate lazy var amount = AnyObserver<String?>.init { event in
    if case .next(let str) = event, let newAmount = str {
      self.item.amount = newAmount
    }
  }
  fileprivate lazy var description = AnyObserver<String?>.init { event in
    if case .next(let str) = event, let newDescription = str {
      self.item.itemDescription = newDescription
    }
  }
  
  fileprivate lazy var imgUploadObserver = AnyObserver<UIImage>.init { event in
    switch event {
    case .next(let img):
      self.uploadImage(img)
    default:
      self.cancelUpload()
    }
  }
  
  fileprivate let imgUploadSubj = BehaviorSubject<Double>(value:0)
  fileprivate (set) lazy var imgUpload:Observable<Double> = self.imgUploadSubj.asObservable()

  fileprivate var uploadTask:StorageUploadTask?{
    didSet{
      
      uploadTask?.observe(.progress) {[unowned self] snapshot in
        if let progress = snapshot.progress{
          self.imgUploadSubj.onNext(progress.fractionCompleted)
        }
      }
      
      uploadTask?.observe(.failure){[unowned self] snapshot in
        
        self.imgUploadSubj.onError(ImageUploadError.failed)
        
      }
      uploadTask?.observe(.success, handler: { [weak self] snapshot in
        self?.imgUploadSubj.onCompleted()
        self?.item.imageID = snapshot.reference.name
      })
    }
  }

  
  init(item:GroceryItem, title:Observable<String?>, amount:Observable<String?>, description:Observable<String?>, imageUploadEvent:Observable<UIImage>)
  {
    self.item = item
    title.bind(to: self.title).disposed(by: disposeBag)
    amount.bind(to: self.amount).disposed(by: disposeBag)
    description.bind(to: self.description).disposed(by: disposeBag)
    imageUploadEvent.bind(to: self.imgUploadObserver).disposed(by: disposeBag)
    
  }
  
  
  func uploadImage(_ image:UIImage)
  {
    let imgItemRef = item.ref.child("imageID")
    
    let imgID = imgItemRef.childByAutoId().key
    let imgStoreRef = storageRef.child(imgID + ".png")
    
    guard let png = UIImagePNGRepresentation(image) else{
      imgUploadSubj.onError(ImageUploadError.failedWithMessage("Failed to convert the image into png."))
      return
    }
    uploadTask = imgStoreRef.putData(png, metadata: nil)
  }
  
  func cancelUpload()
  {
    uploadTask?.cancel()
  }
  
  
  func save()
  {
    item.ref.updateChildValues(item.jsonStr)
  }
  
}
