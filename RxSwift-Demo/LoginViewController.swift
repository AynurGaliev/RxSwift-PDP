//
//  LoginViewController.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 11.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBAction func login(sender: UIButton) {
        VKSdk.wakeUpSession([VK_PER_FRIENDS]) { (state: VKAuthorizationState, error: NSError!) in
            if state != .Authorized {
                VKSdk.authorize([VK_PER_FRIENDS])
            } else {
                guard let lToken = VKSdk.accessToken().accessToken else { return }
                self.performSegueWithIdentifier("showFriendsSegue", sender: lToken)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.tokenDidReceived(_:)), name: "tokenDidReceived", object: nil)
    }
    
    func tokenDidReceived(notification: NSNotification) {
        
        if let token = notification.object as? String {
            self.performSegueWithIdentifier("showFriendsSegue", sender: token)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let lIdentifier = segue.identifier where lIdentifier == "showFriendsSegue" {
            let destinationVC = segue.destinationViewController as! SearchViewController
            guard let lToken = sender as? String else { return }
            destinationVC.prepareController(withToken: lToken)
        } else {
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
