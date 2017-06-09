//
//  LoginVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import FirebaseAuth


protocol LoginVMType {
  
  associatedtype H
  
  func createUser(_ username:String, password:String, handler:@escaping (Error?)->())
  func signIn(_ username:String, password:String)
  var signInHandler:H {get}
}

final class LoginVM:LoginVMType{

  typealias H = (Bool)->()
  
  let signInHandler: H
  
  init(signInHandler:@escaping H)
  {
    self.signInHandler = signInHandler
    
    Auth.auth().addStateDidChangeListener() { auth, user in
      
      signInHandler(user != nil)
    }
  }
  
  func createUser(_ username: String, password: String, handler:@escaping (Error?)->())
  {
    Auth.auth().createUser(withEmail: username, password: password) { user, error in
      handler(error)
    }
  }
  
  func signIn(_ username: String, password: String)
  {
    
    Auth.auth().signIn(withEmail: username, password: password)

  }
  
}
