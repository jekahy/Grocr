//
//  GroceryItemEditVM.swift
//  Grocr
//
//  Created by Eugene on 10.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import RxSwift

final class GroceryItemEditVM{

  fileprivate let disposeBag = DisposeBag()
  fileprivate var item:GroceryItem
  fileprivate let api:APIProtocol.Type
  
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

  
  init(api:APIProtocol.Type, item:GroceryItem, title:Observable<String?>, amount:Observable<String?>, description:Observable<String?>)
  {
    self.api = api
    self.item = item
    title.bind(to: self.title).disposed(by: disposeBag)
    amount.bind(to: self.amount).disposed(by: disposeBag)
    description.bind(to: self.description).disposed(by: disposeBag)
  }
  
  func prepareImageUpload( uploadTrigger:Observable<UIImage> , uploadProgressObserver:AnyObserver<Double>)
  {
    
    var updatedTrigger = uploadTrigger.map { image -> ImageUploader.Command in
      let imgID = self.api.createImageID(for: self.item)
      self.item.imageID = imgID
      return .startUpload(image, imgID)
    }
    
    
    updatedTrigger = updatedTrigger.do(onDispose: {
      self.item.imageID = nil
    })
    
    _ = ImageUploader(trigger: updatedTrigger, progressObserver: uploadProgressObserver)

  }
  
  
  func save()
  {
    item.ref.updateChildValues(item.jsonStr)
  }
  
}
