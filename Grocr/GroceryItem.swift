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
 * OUT OF OR IN CONNECTION WITH TFirebase/CoreHE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import FirebaseDatabase
import FirebaseStorage
import ObjectMapper
import RxSwift

struct GroceryItem:FRModel {
  
  fileprivate let storageRef = Storage.storage().reference().child("grocery-items-images")

  var ref: DatabaseReference!
  var key: String!
  
  var name  = ""
  var addedByUser:String?
  var description:String?
  var createdAt = Date()
  var groceryID:String!
  var amount:String?
  var itemDescription:String?
  var completed = false
  var imageID:String?
  var imageURL:Observable<URL?>?{
    let storageRef = Storage.storage().reference().child("grocery-items-images")
    if let imgID = imageID{
      return storageRef.child(imgID).downloadURL
    }
    return nil
  }
  
  init?(map: Map) {}

  init(name: String, addedByUser: String?, groceryID:String, ref:DatabaseReference, completed: Bool = false, amount:String?=nil, description:String? = nil)
  {
    self.name = name
    self.addedByUser = addedByUser
    self.groceryID = groceryID
    self.completed = completed
    self.ref = ref
    self.key = ref.key
    self.createdAt = Date()
    self.itemDescription = description
    self.amount = amount
  }

  mutating func mapping(map: Map)
  {
    name 	<- map["name"]
    createdAt	<- (map["createdAt"], DateTransform())
    addedByUser <- map["addedByUser"]
    groceryID <- map["groceryID"]
    completed <- map["completed"]
    itemDescription <- map["description"]
    amount <- map["amount"]
    imageID <- map["imageID"]
    
  }

}
