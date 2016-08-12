//
//  LoadingFooterView.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 04.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class LoadingFooterView: UITableViewHeaderFooterView {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var retryButton: UIButton!
    
    var retry: ((sender: UIButton) -> Void)?
    
    var isLoading: Bool = true {
        didSet {
            self.activityIndicatorView.hidden = !isLoading
            self.retryButton.hidden = isLoading
        }
    }
    
    @IBAction func retry(sender: UIButton) {
        self.retry?(sender: sender)
    }
}
