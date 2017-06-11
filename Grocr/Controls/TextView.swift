//
//  TextView.swift
//  Grocr
//
//  Created by Eugene on 10.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import UIKit

class TextView: UITextView, Editable {

  fileprivate var originalBgColor:UIColor!
  
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    originalBgColor = self.backgroundColor
  }
  
  func enableEditMode()
  {
    backgroundColor = editBGColor
    isEditable = true
  }
  
  func disableEditMode()
  {
    backgroundColor = originalBgColor
    isEditable = false
  }
}
