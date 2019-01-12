//
//  Category.swift
//  MyToDoList
//
//  Created by Rosa Mejia on 1/11/19.
//  Copyright © 2019 Rosa Mejia. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object  {
    @objc dynamic var name: String = ""
    @objc dynamic var backgroundColor: String = ""
    let items = List<Item>()
}
