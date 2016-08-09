//
//  Friend.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 04.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

public class Friend {

    var firstName: String = ""
    var lastName : String = ""
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName  = lastName
    }
    
    var fullName: String {
        return self.firstName + " " + self.lastName
    }
    
    init() {}
}
