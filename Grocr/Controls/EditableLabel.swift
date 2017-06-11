//
//  EditableLabel.swift
//  Grocr
//
//  Created by Eugene on 10.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class EditableLabel: UILabel, Editable {
  
  lazy var textInput:Observable<String?> = self.textField.rx.text.asObservable()
  
  fileprivate lazy var textField:UITextField = UITextField(frame: self.bounds)


  override func awakeFromNib()
  {
    super.awakeFromNib()
    self.addSubview(textField)
    textField.isHidden = true
    textField.textAlignment = self.textAlignment
    textField.font = self.font
    textField.backgroundColor = editBGColor
    textField.autocorrectionType = .no

    isUserInteractionEnabled = true
  }
  
  
  func enableEditMode()
  {
    textField.isHidden = false
  }
  
  
  func disableEditMode()
  {
    text = textField.text
    textField.isHidden = true
    
  }
  
  override var isHidden: Bool{
    didSet{
      super.isHidden = isHidden
      textField.isHidden = isHidden
    }
  }
  
  override func layoutSubviews()
  {
    super.layoutSubviews()
    textField.frame = bounds
  }
  
  
  
}


extension Reactive where Base: EditableLabel {
  
  /// Bindable sink for `text` property.
  var texttt: UIBindingObserver<Base, String?> {
    return UIBindingObserver(UIElement: self.base) { label, text in
      label.text = text
      label.textField.text = text
    }
  }
  
  /// Bindable sink for `attributedText` property.
  var attributedTexttt: UIBindingObserver<Base, NSAttributedString?> {
    return UIBindingObserver(UIElement: self.base) { label, text in
      label.attributedText = text
      label.textField.attributedText = text
    }
  }
}

