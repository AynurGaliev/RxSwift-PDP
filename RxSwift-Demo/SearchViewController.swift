//
//  MasterViewController.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 04.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol ISearchView {
    var searchTableView: UITableView { get }
    func setTotalFriendsCount(text: String)
    var searchTextObservable       : Observable<String> { get }
    func reloadTableView()
    func reloadIndexPaths(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation)
    func setLoadingState(isLoading: Bool)
}

class SearchViewController: UIViewController {

    //MARK: - UI Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var totalCountLabel: UILabel!
    private var disposeBag: DisposeBag = DisposeBag()
    
    private lazy var loadingView: LoadingFooterView = { 
        let view = NSBundle.mainBundle().loadNibNamed("LoadingFooterView", owner: nil, options: nil).first! as! LoadingFooterView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 44)
        return view
    }()
    
    private lazy var presenter: ISearchPresenter = {[weak self] in
        let presenter = SearchPresenter(view: self)
        self?.tableView.setAdapter(presenter)
        return presenter
    }()
    
    override func viewWillLayoutSubviews() {
        self.tableView.tableFooterView?.frame.size.height = 44.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = self.presenter
        self.tableView.registerNib(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        self.tableView.tableFooterView = self.loadingView
    }
}


extension SearchViewController: ISearchView {
    
    var searchTableView: UITableView {
        return self.tableView
    }
    
    func setTotalFriendsCount(text: String) {
        self.totalCountLabel.text = text ?? ""
    }
    
    var searchTextObservable: Observable<String> {
        return self.searchBar.rx_text.asObservable()
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func reloadIndexPaths(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation) {
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        self.tableView.endUpdates()
    }
    
    func setLoadingState(isLoading: Bool) {
        UIView.animateWithDuration(0.5) { 
            if isLoading {
                if self.tableView.tableFooterView == nil {
                    self.tableView.tableFooterView = self.loadingView
                }
            } else {
                self.tableView.tableFooterView = nil
            }
        }
    }
}
