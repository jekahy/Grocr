//
//  GRListsCell.swift
//  Grocr
//
//  Created by Eugene on 29.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GroceryCell: UITableViewCell {
  
  fileprivate let diposeBag = DisposeBag()
  
  @IBOutlet weak var titleLab: UILabel!
  @IBOutlet weak var itemCountLab: UILabel!
  
  var groceryVM: GroceryListItemVMType? {
    
    didSet{
      guard let grItemModel = groceryVM else {
        return
      }
      grItemModel.title.drive(titleLab.rx.text).disposed(by:self.diposeBag)
      grItemModel.count.drive(itemCountLab.rx.text).disposed(by:self.diposeBag)
    }
  }
  
}
