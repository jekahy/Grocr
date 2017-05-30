/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import FirebaseAuth
import SwiftValidator

class LoginVC: UIViewController, Validatable, EasyAlert {
  
  fileprivate typealias EmptyClosure = ()->()
  
  // MARK: Constants
  fileprivate let loginToList = "LoginToList"
  fileprivate let validationFailedMess = "It looks like something is wrong with the input data. Here what we've found: "
  fileprivate let willCheckTitle = "OK, I'll check it out"
  
  let validator = Validator()
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: TextField!
  @IBOutlet weak var textFieldLoginPassword: TextField!
  
  enum ValidationRules {
    
    case email
    case password
    case confirmation(UITextField)
    
    func rules() -> [Rule]
    {
      switch self {
      case .email:
        return [RequiredRule(message: "email is missing"), EmailRule(message: "email is invalid")]
      case .password:
        return [RequiredRule(message: "password is missing"), MinLengthRule(length:6, message: "password is too short")]
      case .confirmation(let passTF):
        return [ConfirmationRule(confirmField: passTF, message:"passwords don't match")]
      }
      
    }
  }
  
  //MARK: Methods

  override func viewDidLoad()
  {
    super.viewDidLoad()
    addAuthListener()
    setupValidator()
  }
  
  fileprivate func addAuthListener()
  {
    Auth.auth().addStateDidChangeListener() { auth, user in
      
      if user != nil {
        
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
        
      }
    }
  }
  
  func setupValidator()
  {
    validator.styleTransformers(success: { validationRule in
      
      if let tf = validationRule.field as? TextField  {
        tf.removeErrorHighlight()
      }
    }) { validationError in
      
      if let tf = validationError.field as? TextField  {
        tf.highlightError()
      }
    }
    validator.registerField(textFieldLoginEmail, rules: .email)
    validator.registerField(textFieldLoginPassword, rules: .password)
  }
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject)
  {
    validateFields {[weak self] in
      if let strSelf = self{
        Auth.auth().signIn(withEmail: strSelf.textFieldLoginEmail.text!,
                           password: strSelf.textFieldLoginPassword.text!)
      }
    }
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject)
  {
    validateFields {[weak self] in
      if let alert = self?.signUpAlert(){
        self?.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  //MARK: Methods
  
  fileprivate func validateFields(success:@escaping EmptyClosure)
  {
    validator.validate {[unowned self] errors in
      
      if errors.count > 0 {
        let issues = errors.map{ $1.errorMessage}.joined(separator: ", ")
        let finalMess = self.validationFailedMess + "\(issues)."
        self.showAlert("Hey", message: finalMess, alertActions: [.okWithTitle(self.willCheckTitle)])
        
      }else{
        success()
      }
    }
  }
  
  fileprivate func signUpAlert()->UIAlertController
  {
    let alert = UIAlertController(title: "Register",
                                  message: "Register",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) {[weak self] action in
      
      
      guard let confTF = alert.textFields?[0], let strSelf = self else {
        return
      }
      strSelf.validator.registerField(confTF, rules:.confirmation(strSelf.textFieldLoginPassword))
      strSelf.validator.validateField(confTF, callback: { error in
        
        if let error = error {
          
          let finalMess = strSelf.validationFailedMess + "\(error.errorMessage)."
          strSelf.showAlert("Hey", message: finalMess, alertActions: [.okWithTitle(strSelf.willCheckTitle)])
          strSelf.validator.unregisterField(confTF)
          
        }else{
          
          Auth.auth().createUser(withEmail: strSelf.textFieldLoginEmail.text!, password: confTF.text!) { user, error in
            if error == nil {
              
              Auth.auth().signIn(withEmail: strSelf.textFieldLoginEmail.text!,
                                 password: strSelf.textFieldLoginPassword.text!)
            }else{
              strSelf.showAlert("OOpss", message: "Something went wrong :/ (\(error!.localizedDescription)).", alertActions: [.ok])
            }
          }
        }
      })
    }
    
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Password confirmation"
    }
    
    alert.addAction(saveAction)
    alert.addAction(.cancel)
    return alert
  }
  
}

extension LoginVC: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool
  {
    guard let tf =  textField as? TextField else{
      return true
    }
    if let next = tf.nextResp{
      next.becomeFirstResponder()
    }else{
      tf.resignFirstResponder()
    }
    return true
  }
}
