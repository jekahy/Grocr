//
//  StorageReferenceExtension.swift
//  Grocr
//
//  Created by Eugene on 11.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//


import FirebaseStorage
import RxSwift


extension StorageReference {
  
  var downloadURL:Observable<URL?> {
    return Observable.create({ observer -> Disposable in
      self.downloadURL(completion: { url, error in
        if let err = error{
          observer.onError(err)
        }else{
          observer.onNext(url)
        }
      })
      return Disposables.create()
    })
  }
}
