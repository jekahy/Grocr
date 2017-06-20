//
//  ImageUploader.swift
//  Grocr
//
//  Created by Eugene on 17.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import FirebaseStorage
import RxSwift

final class ImageUploader {
  
  enum Command {
    case triggerUpload(UIImage)
    case startUpload(UIImage, String)
    case cancel
  }
  
  fileprivate let storageRef = Storage.storage().reference().child("grocery-items-images")
  fileprivate let uploadProgressSubj = BehaviorSubject<Double>(value:0)
  fileprivate let disposeBag = DisposeBag()
  fileprivate let trigger:Observable<Command>
  
  fileprivate var uploadTask:StorageUploadTask?{
    didSet{
      
      uploadTask?.observe(.progress) {[weak self] snapshot in
        if let progress = snapshot.progress{
          self?.uploadProgressSubj.onNext(progress.fractionCompleted)
        }
      }
      
      uploadTask?.observe(.failure){[weak self] snapshot in
        
        self?.uploadProgressSubj.onError(ImageUploadError.failed)
        
      }
      uploadTask?.observe(.success, handler: { [weak self] snapshot in
        self?.uploadProgressSubj.onCompleted()
      })
    }
  }
  
  
  init(trigger:Observable<Command>, progressObserver:AnyObserver<Double>)
  {
    self.trigger = trigger
    
    
    trigger.subscribe(onNext: {command in
      
      switch command {
      case .startUpload(let img, let imgID):
          let progress = self.uploadImage(img, imageName: imgID)
          progress.bind(to: progressObserver).disposed(by: self.disposeBag)
        
      default:
        self.uploadTask?.cancel()
      }
    }, onCompleted:{
      self.uploadTask?.cancel()
    }).disposed(by: disposeBag)
    
  }
  
  private func uploadImage(_ image:UIImage, imageName:String)->Observable<Double>
  {
    let imgStoreRef = storageRef.child(imageName + ".png")
    guard let png = UIImagePNGRepresentation(image) else{
      uploadProgressSubj.onError(ImageUploadError.failedWithMessage("Failed to convert the image into png."))
      return uploadProgressSubj.asObservable()
    }
    uploadTask = imgStoreRef.putData(png, metadata: nil)
    return uploadProgressSubj.asObservable()
  }
  
}

