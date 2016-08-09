//
//  NetworkService.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 08.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol INetworkService {
    var isReachable: Observable<Bool> { get }
}

class NetworkService: INetworkService {
    
    private(set) var isReachable: Observable<Bool>
    
    init() {
        self.isReachable = AFNetworkReachabilityManager
                            .sharedManager()
                            .rx_observe(Bool.self, "reachable")
                            .filter { $0 != nil }
                            .map { $0! }
    }
}