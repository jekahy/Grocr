//
//  AlertActionExtension.swift
//  Grocr
//
//  Created by Eugene on 27.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertAction{
  
  typealias Handler = (UIAlertAction)->()
  enum DefaultAction {
    case ok
    case cancel
    case okWithHandler(Handler)
    case okWithTitle(String)
    case okWithHandlerAndTitle(Handler, String)
    case cancelWithHandler(Handler)
    case cancelWithTitle(String)
    case cancelWithHandlerAndTitle(Handler, String)
    
    var action:UIAlertAction {
      
      switch self {
      case .ok:
        return UIAlertAction(title: "OK", style: .default, handler: nil)
      case .cancel:
        return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      case .okWithHandler(let handler):
        return UIAlertAction(title: "OK", style: .default, handler: handler)
      case .okWithTitle(let title):
        return UIAlertAction(title: title, style: .default, handler: nil)
      case .okWithHandlerAndTitle(let handler, let title):
        return UIAlertAction(title: title, style: .default, handler: handler)
      case .cancelWithHandler(let handler):
        return UIAlertAction(title: "Cancel", style: .cancel, handler: handler)
      case .cancelWithTitle(let title):
        return UIAlertAction(title: title, style: .cancel, handler: nil)
      case .cancelWithHandlerAndTitle(let handler,let title):
        return UIAlertAction(title: title, style: .cancel, handler: handler)
      }
    }
  }

  
}
