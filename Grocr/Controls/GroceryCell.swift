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

class GroceryCell: UITableViewCell, ViewModelAvailable {
  
  typealias VM = GroceryListItemVMType
  fileprivate var disposeBag = DisposeBag()
  
  @IBOutlet weak var titleLab: UILabel!
  @IBOutlet weak var itemCountLab: UILabel!
  
  weak var viewModel: VM? {
    
    didSet{
      guard let grItemModel = viewModel else {
        return
      }
      grItemModel.title.drive(titleLab.rx.text).disposed(by:self.disposeBag)
      grItemModel.count.drive(itemCountLab.rx.text).disposed(by:self.disposeBag)
    }
  }
  
  override func prepareForReuse()
  {
    super.prepareForReuse()
    viewModel = nil
    disposeBag = DisposeBag()
  }
}
