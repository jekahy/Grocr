//
//  GenericRxCell.swift
//  Grocr
//
//  Created by Eugene on 06.06.17.
//  Copyright © 2017 Eugene. All rights reserved.
//

import UIKit

class GenericCell: UITableViewCell, ViewModelAvailable  {

  
  typealias VM = AnyObject
  
  weak var viewModel:VM?
}
