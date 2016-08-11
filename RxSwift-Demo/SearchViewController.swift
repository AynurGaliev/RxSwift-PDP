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
    var searchTextObservable       : Observable<(Int, String)> { get }
    func reloadTableView()
    func reloadIndexPaths(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation)
    func setLoadingState(isLoading: Bool)
    func setEmptyResult()
}

class SearchViewController: UIViewController {

    //MARK: - UI Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var totalCountLabel: UILabel!
    private var disposeBag: DisposeBag = DisposeBag()
    private var token: String = ""
    
    private lazy var loadingView: LoadingFooterView = { 
        let view = NSBundle.mainBundle().loadNibNamed("LoadingFooterView", owner: nil, options: nil).first! as! LoadingFooterView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 44)
        return view
    }()
    
    private lazy var emptyResultView: EmptyResultView = {
        let view = NSBundle.mainBundle().loadNibNamed("EmptyResultView", owner: nil, options: nil).first! as! EmptyResultView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height)
        return view
    }()
    
    private lazy var presenter: ISearchPresenter = {[weak self] in
        let presenter = SearchPresenter(view: self!)
        self?.tableView.setAdapter(presenter)
        return presenter
    }()
    
    override func viewWillLayoutSubviews() {
        self.tableView.tableFooterView?.frame.size.height = 44.0
    }
    
    func prepareController(withToken token: String) {
        self.token = token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = self.presenter
        self.tableView.registerNib(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        self.tableView.tableFooterView = self.loadingView
        
//        self.searchBar.rx_text.subscribeNext { (query: String) in
//            print("Some")
//        }.addDisposableTo(self.disposeBag)
//        
//        self.tableView.rx_willDisplayCell.subscribeNext { (value: (cell: UITableViewCell, indexPath: NSIndexPath)) in
//            print(value.indexPath)
//        }.addDisposableTo(self.disposeBag)
    }
}


extension SearchViewController: ISearchView {
    
    var searchTableView: UITableView {
        return self.tableView
    }
    
    func setTotalFriendsCount(text: String) {
        self.totalCountLabel.text = text ?? ""
    }
    
    var searchTextObservable: Observable<(Int, String)> {

        let willDisplayObservable = self.tableView
                            .rx_willDisplayCell
                            .debug("RxWillDisplay")
                            .flatMap({ (value: WillDisplayCellEvent) -> Observable<Int> in
                                return Observable.of(value.indexPath.row)
                            })
                            .shareReplayLatestWhileConnected()
                            .startWith(0)
        
        let searchBarText = self.searchBar
                            .rx_text
                            .shareReplayLatestWhileConnected()
                            .debug("RxText")
        
        return Observable.combineLatest(willDisplayObservable, searchBarText, resultSelector: { (index: Int, query: String) -> (index: Int, query: String) in
            return (index: index, query: query)
        })
        .debug("Combine")
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
    
    func setEmptyResult() {
        UIView.animateWithDuration(0.5) { 
            self.tableView.tableFooterView = self.emptyResultView
        }
    }
}
