//
//  GRListsCell.swift
//  Grocr
//
//  Created by Eugene on 29.05.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import UIKit

class GRListsCell: UITableViewCell {
  
  @IBOutlet weak var titleLab: UILabel!
  @IBOutlet weak var itemCountLab: UILabel!
  
  var grocery:Grocery!
  
  func configure(_ grocery:Grocery)
  {
    self.grocery = grocery
    titleLab.text = grocery.name
    itemCountLab.text = "\(grocery.items.count)"
  }
}
