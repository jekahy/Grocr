//
//  ImageUploadError.swift
//  Grocr
//
//  Created by Eugene on 15.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

enum ImageUploadError:Error {
  
  case failedWithMessage(String)
  case failed
  case cancelled
}
