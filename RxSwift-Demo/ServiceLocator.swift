//
//  ServiceLocator.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 08.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

public class ServiceLocator {
    
    private init() { }
    private static var registry : [String : Any] = [:]
    
    public class func registerService<T>(service: T) {
        let key = "\(T.self)"
        self.registry[key] = service
    }
    
    public class func getService<T>() -> T? {
        let key = "\(T.self)"
        return self.registry[key] as? T
    }
    
    public static func setupDependencies() {
        ServiceLocator.registerService(NetworkService() as INetworkService)
        ServiceLocator.registerService(FriendsService(sessionManager: sessionManager) as IFriendsService)
    }
    
    private static var sessionManager: AFHTTPSessionManager = {
        let baseURL = (NSBundle.mainBundle().objectForInfoDictionaryKey("baseURL") as! String).toURL
        let manager: AFHTTPSessionManager = AFHTTPSessionManager(baseURL: baseURL)
        manager.requestSerializer         = AFJSONRequestSerializer(writingOptions: NSJSONWritingOptions.PrettyPrinted)
        manager.responseSerializer        = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
        manager.completionQueue           = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

        return manager
    }()
}