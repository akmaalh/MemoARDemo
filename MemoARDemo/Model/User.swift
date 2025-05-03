//
//  User.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import Foundation

struct User: Codable {
    var name: String
    var age: Int
    var highScore: Int = 0
    
    static let empty = User(name: "", age: 0)
}
