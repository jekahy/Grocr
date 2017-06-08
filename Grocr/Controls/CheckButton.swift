//
//  CheckButton.swift
//  Grocr
//
//  Created by Eugene on 01.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class CheckButton: UIButton {
  
  
  @IBInspectable var checkedImage:UIImage?
  @IBInspectable var unCheckedImage:UIImage?
  
  @IBInspectable var borderColor:UIColor = UIColor.gray {
    didSet{ self.layer.borderColor = self.borderColor.cgColor}}
  
  @IBInspectable var borderWidth:CGFloat = 4 {
    didSet{ self.layer.borderWidth = self.borderWidth}}
  
  @IBInspectable var cornerRadius:CGFloat = 5 {
    didSet{ self.layer.cornerRadius = self.cornerRadius }}

  
  fileprivate var disposeBag:DisposeBag! = DisposeBag()
  
  var checked = false {
    didSet {
      if self.checked {
        setImage(checkedImage, for: UIControlState.normal)
      } else {
        setImage(unCheckedImage, for: UIControlState.normal)
      }
    }
  }
  
  let setCompleted = Variable(false)
 
  fileprivate(set) lazy var updateCompleted:Observable<Bool> = Observable<Bool>.create({[weak self] observer -> Disposable in
    
    guard let strSelf = self else{
      return Disposables.create()
    }
    strSelf.rx.controlEvent(.touchUpInside).subscribe(onNext: {[unowned strSelf] in
      
      strSelf.checked = !strSelf.checked
      observer.onNext(strSelf.checked)
    }).disposed(by: strSelf.disposeBag)
    return Disposables.create()
  })

  
  override func awakeFromNib()
  {
    setCompleted.asObservable().subscribe(onNext: {[weak self] newVal in
      self?.checked = newVal
    }).disposed(by: disposeBag)
    
  }
  
  deinit {
    disposeBag = nil
  }
  
}

extension CheckButton {
  var driveChecked: AnyObserver<Bool> {
    return UIBindingObserver(UIElement: self) { but, isChecked in
      but.checked = isChecked
      }.asObserver()
  }
}
