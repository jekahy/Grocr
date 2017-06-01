//
//  LoginVM.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import RxSwift
import FirebaseAuth


protocol LoginVMType {
  
  func createUser(_ username:String, password:String, handler:@escaping (Error?)->())
  func signIn(_ username:String, password:String)
  var signInObservable: Observable<Bool> {get}
}

final class LoginVM:LoginVMType{

  lazy var signInObservable: Observable<Bool> =  self.signInVariable.asObservable()
  fileprivate let signInVariable = Variable<Bool>(false)
  
  init()
  {
    Auth.auth().addStateDidChangeListener() { auth, user in
      
      if user != nil {
        
        self.signInVariable.value = true
        
      }
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
