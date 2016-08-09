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
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var disposeBag: DisposeBag = DisposeBag()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ServiceLocator.setupDependencies()
        return true
    }
}
