//
//  FriendsService.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 04.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum FriendsServiceError: ErrorType {
    case SomeError
}

protocol IFriendsService {
    func API_fetchFriends(userId: Int, count: Int, offset: Int) -> Observable<[Friend]>
    func API_searchFriends(userId: Int, query: String, count: Int, offset: Int) -> Observable<[Friend]>
}

public class FriendsService: IFriendsService {

    let baseURL: NSURL = NSURL(string: "http://api.vk.com/method/")!
    let disposeBag: DisposeBag = DisposeBag()
    
    private var sessionManager: AFHTTPSessionManager = ServiceLocator.getService()!
    
    func API_fetchFriends(userId: Int, count: Int, offset: Int) -> Observable<[Friend]> {
        
        return Observable.create { (observer: AnyObserver<[Friend]>) -> Disposable in
            
            var params: Dictionary<String, AnyObject> = ["user_id" : userId, "count" : count, "offset" : offset, "fields" : "name"]
            if let lToken = VKSdk.accessToken().accessToken { params["access_token"] = lToken }
            let task = self.sessionManager
                .GET("friends.get",
                     parameters: params,
                     progress: nil,
                     success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                    
                    guard let lResponse = response as? Dictionary<String, AnyObject> else {
                        observer.onError(FriendsServiceError.SomeError)
                        return
                    }
                    guard let friendsDict = lResponse["response"] as? Array<Dictionary<String, AnyObject>> else {
                        observer.onError(FriendsServiceError.SomeError)
                        return
                    }
                    
                    var friends: [Friend] = []
                    for dict in friendsDict {
                        let firstName = dict["first_name"] as? String ?? ""
                        let lastName = dict["last_name"] as? String ?? ""
                        let friend = Friend(firstName: firstName, lastName: lastName)
                        friends.append(friend)
                    }
                    observer.onNext(friends)
                    observer.onCompleted()
                    
                }) { (task: NSURLSessionDataTask?, error: NSError) in
                    observer.onError(error)
                }
                //return NopDisposable.instance
            return AnonymousDisposable.init({
                task?.cancel()
                print("Disposed at \(#line) in \(#file)")
            })
        }
    }
    
    func API_searchFriends(userId: Int, query: String, count: Int, offset: Int) -> Observable<[Friend]> {
        
        return Observable.create { (observer: AnyObserver<[Friend]>) -> Disposable in
            
            var params: Dictionary<String, AnyObject> = ["user_id" : userId,
                                                         "count"   : count,
                                                         "offset"  : offset,
                                                         "fields"  : "name",
                                                         "q"       : query]
            if let lToken = VKSdk.accessToken().accessToken { params["access_token"] = lToken }
            
            let task = self.sessionManager
                .GET("friends.search",
                    parameters: params,
                    progress: nil,
                    success: { (task: NSURLSessionDataTask, response: AnyObject?) in
                        
                        guard let lResponse = response as? Dictionary<String, AnyObject> else {
                            observer.onError(FriendsServiceError.SomeError)
                            return
                        }
                        guard var friendsDict = lResponse["response"] as? Array<AnyObject> else {
                            observer.onError(FriendsServiceError.SomeError)
                            return
                        }
                        friendsDict.removeFirst()
                        
                        guard let friendsArray = friendsDict as? Array<Dictionary<String, AnyObject>> else {
                            observer.onError(FriendsServiceError.SomeError)
                            return
                        }
                        var friends: [Friend] = []
                        for dict in friendsArray {
                            let firstName = dict["first_name"] as? String ?? ""
                            let lastName = dict["last_name"] as? String ?? ""
                            let friend = Friend(firstName: firstName, lastName: lastName)
                            friends.append(friend)
                        }
                        observer.onNext(friends)
                        observer.onCompleted()
                        
                }) { (task: NSURLSessionDataTask?, error: NSError) in
                    observer.onError(error)
            }
            
            //return NopDisposable.instance
            return AnonymousDisposable.init({
                task?.cancel()
                print("Disposed at \(#line) in \(#file)")
            })
        }
    }

    
}
