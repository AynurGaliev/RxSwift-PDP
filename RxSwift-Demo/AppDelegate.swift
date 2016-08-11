//
//  AppDelegate.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 04.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var disposeBag: DisposeBag = DisposeBag()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ServiceLocator.setupDependencies()
        
        let vkInstance = VKSdk.initializeWithAppId("5253935")
        
        vkInstance.registerDelegate(self)
        vkInstance.uiDelegate = self
        
        let observable =
            Observable.create { (observer: AnyObserver<Int>) -> Disposable in
            observer.onNext(1)
            observer.onCompleted()
            
            return AnonymousDisposable.init({ 
                print("Disposed!")
            })
        }
        
        observable.subscribeNext { (value: Int) in
            print(value)
        }.addDisposableTo(self.disposeBag)
        
        
        let subject = PublishSubject<Int>()
        
        subject.subscribeNext { (value) in
            print(value)
        }.addDisposableTo(self.disposeBag)
        
        subject.onNext(1)
        
        subject.onCompleted()
        
        subject.onNext(2)
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String)
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        VKSdk.processOpenURL(url, fromApplication: sourceApplication)
        return true
    }
}

extension AppDelegate: VKSdkDelegate {
    
    func vkSdkAccessAuthorizationFinishedWithResult(result: VKAuthorizationResult!) {
    
        if let lToken = result?.token?.accessToken {
            NSNotificationCenter.defaultCenter().postNotificationName("tokenDidReceived", object: lToken)
        }
        
        let navController = self.window!.rootViewController as! UINavigationController
        navController.topViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func vkSdkUserAuthorizationFailed() {
        
    }
}

extension AppDelegate: VKSdkUIDelegate {
    
    func vkSdkShouldPresentViewController(controller: UIViewController!) {
        let navController = self.window!.rootViewController as! UINavigationController
        navController.topViewController!.presentViewController(controller, animated: true, completion: nil)
    }
    
    func vkSdkNeedCaptchaEnter(captchaError: VKError!) {
    
    }
    
}