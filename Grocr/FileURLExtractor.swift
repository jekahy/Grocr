//
//  URLExtractor.swift
//  Grocr
//
//  Created by Eugene on 13.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import FirebaseStorage
import RxSwift

struct FileURLExtractor {
  
  static let storageRef = FIRStorageLocations.images.reference()
  
  static func imageURL(_ imageID:String?) -> Observable<URL?>?
  {
    if let imageID = imageID{
      return storageRef.child(imageID).downloadURL
    }
    return nil
  }
  
}
