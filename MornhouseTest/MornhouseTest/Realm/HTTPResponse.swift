//
//  HTTPResponse.swift
//  MornhouseTest
//  DataModel: Response table
//  Created by Anatoly on 25.10.2022.
//

import Foundation
import RealmSwift

class Response: Object {
    @objc dynamic var num    = ""
    @objc dynamic var answer = ""
}
