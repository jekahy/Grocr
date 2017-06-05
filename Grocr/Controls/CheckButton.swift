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

  
  fileprivate let disposeBag = DisposeBag()
  
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
  fileprivate(set) var updateCompleted = Observable<Bool>.empty()
  
  override func awakeFromNib()
  {
    setCompleted.asObservable().subscribe(onNext: {[weak self] newVal in
      self?.checked = newVal
    }).disposed(by: disposeBag)
    
    updateCompleted = Observable<Bool>.create({[unowned self] observer -> Disposable in
      
      self.rx.controlEvent(.touchUpInside).subscribe(onNext: {
        
        self.checked = !self.checked
        observer.onNext(self.checked)
        
      }).disposed(by: self.disposeBag)
      return Disposables.create()
    })
    
  }
}

extension CheckButton {
  var driveChecked: AnyObserver<Bool> {
    return UIBindingObserver(UIElement: self) { but, isChecked in
      but.checked = isChecked
      }.asObserver()
  }
}



















//
//extension Reactive where Base: CheckButton {
//  
//  var isChecked: ControlProperty<Bool> {
//    return value
//  }
//  
//  var value: ControlProperty<Bool> {
//    return UIControl.valuePublic(
//      control: self.base,
//      getter: { button in
//        button.checked
//    }, setter: { button, value in
//      button.checked = value
//    })
//  }
//
//  
//  
//}
//
//extension UIControl {
//  static func valuePublic<T, ControlType: UIControl>(control: ControlType, getter: @escaping (ControlType) -> T, setter: @escaping (ControlType, T) -> ()) -> ControlProperty<T> {
//    let values: Observable<T> = Observable.deferred { [weak control] in
//      guard let existingSelf = control else {
//        return Observable.empty()
//      }
//      
//      return existingSelf.rx.controlEvent([ .touchUpInside])
//        .flatMap { _ in
//          return control.map { Observable.just(getter($0)) } ?? Observable.empty()
//        }
//        .startWith(getter(existingSelf))
//    }
//    return ControlProperty(values: values, valueSink: UIBindingObserver(UIElement: control) { control, value in
//      setter(control, value)
//    })
//  }
//}
