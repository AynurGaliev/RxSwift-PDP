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

enum LoadingState: Int {
    case Loading
    case Error
}

enum FooterState {
    case NoMatchingResult
    case Info(LoadingState)
    case Hidden
    
    var rawValue: Int {
        switch self {
        case .NoMatchingResult: return 0
        case let .Info(value) where value == .Loading: return 1
        case let .Info(value) where value == .Error: return 2
        case .Hidden: return 3
        default: return -1
        }
    }
}

func !=(lhs: FooterState, rhs: FooterState) -> Bool {
    return lhs.rawValue != rhs.rawValue
}

protocol ISearchView: class {
    var searchTextObservable: Observable<(Int, String)> { get }
    func reloadTableView()
    func reloadIndexPaths(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation)
    func setFooterState(footerState: FooterState)
}

class SearchViewController: UIViewController {

    //MARK: - UI Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var totalCountLabel: UILabel!
    private var disposeBag: DisposeBag = DisposeBag()
    private var token: String = ""
    private var currentFooterState: FooterState = FooterState.Info(.Loading)
    
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
    
    private lazy var presenter: ISearchPresenter = { Void in
        let presenter = SearchPresenter()
        self.tableView.dataSource = presenter
        presenter.setView(self)
        return presenter
    }()
    
    func prepareController(withToken token: String) {
        self.token = token
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = self.presenter
        self.tableView.registerNib(UINib(nibName: "LoadingFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "LoadingFooterView")
        self.tableView.tableFooterView = self.loadingView
        self.loadingView.retry = { _ -> Void in
            self.presenter.retry()
        }
    }
}

extension SearchViewController: ISearchView {
    
    var searchTextObservable: Observable<(Int, String)> {

        return Observable.combineLatest(self.tableView.rx_willDisplayCell,
                                        self.searchBar.rx_text,
            resultSelector: { (index: WillDisplayCellEvent, query: String) -> (index: Int, query: String) in
            return (index: index.indexPath.row, query: query)
        })
        .startWith((0, ""))
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func reloadIndexPaths(indexPaths: [NSIndexPath], animation: UITableViewRowAnimation) {
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Bottom)
        self.tableView.endUpdates()
    }
    
    func setFooterState(footerState: FooterState) {
        
        guard footerState != self.currentFooterState else { return }
        self.currentFooterState = footerState
        
        var animationBlock = { }
        
        switch footerState {
            case .NoMatchingResult:
                animationBlock = {
                    self.loadingView.frame.size.height = self.tableView.frame.size.height
                    self.tableView.tableFooterView = self.emptyResultView
                }
            case let .Info(value) where value == .Error:
                animationBlock = {
                    self.loadingView.frame.size.height = 44.0
                    self.tableView.tableFooterView = self.loadingView
                    self.loadingView.isLoading = false
                }
            case let .Info(value) where value == .Loading:
                animationBlock = {
                    self.loadingView.frame.size.height = 44.0
                    self.tableView.tableFooterView = self.loadingView
                    self.loadingView.isLoading = true
                }
            case .Hidden:
                animationBlock = {
                    self.tableView.tableFooterView = nil
                }
            default:
                return
        }
        
        UIView.animateWithDuration(0.3, animations: animationBlock)
    }
}
