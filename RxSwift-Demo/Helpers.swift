//
//  Helpers.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 08.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import UIKit

protocol TableViewProtocol: UITableViewDataSource, UITableViewDelegate { }

let userId: Int = 71564248

extension UITableView {
    
    func setAdapter(adapter: TableViewProtocol) {
        self.dataSource = adapter
        self.delegate   = adapter
    }
}

func rx_debug(text: String) {
    print("\(text) at line \(#line) in \(#file) ")
}

extension String {
    
    var toURL: NSURL {
        return NSURL(string: self)!
    }
}