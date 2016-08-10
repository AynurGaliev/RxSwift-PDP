//
//  SearchPresenter.swift
//  RxSwift-Demo
//
//  Created by Aynur Galiev on 08.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol ISearchPresenter {
}

class SearchPresenter: NSObject, ISearchPresenter {

    struct Constants {
        static let pageSize: Int = 20
    }
    
    private var friends: [Friend] = []
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var friendsService: IFriendsService = ServiceLocator.getService()!
    private var networkService: INetworkService = ServiceLocator.getService()!
    private var view: ISearchView!
    private var currentQuery: String = ""
    
    init(view: ISearchView) {
        super.init()
        self.view = view

        self.view
          .searchTextObservable
          .flatMap({ (value: (index: Int, query: String)) -> Observable<[Friend]> in
            
                if self.currentQuery != value.query {
                    self.friends = []
                    self.view.reloadTableView()
                }
                self.currentQuery = value.query
                var friendsObservable: Observable<[Friend]>

                if value.index == self.friends.count - 1 || self.friends.count == 0 {
                    if value.query == "" {
                        friendsObservable = self.friendsService.API_fetchFriends(userId, count: Constants.pageSize, offset: self.friends.count)
                    } else {
                        friendsObservable = self.friendsService.API_searchFriends(userId, query: value.query, count: Constants.pageSize, offset: self.friends.count)
                    }
                    return friendsObservable
                } else {
                    return Observable.never()
                }
          })
          .observeOn(MainScheduler.asyncInstance)
          .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS.UserInteractive))
          .subscribe(onNext: { [weak self] (receivedFriends) in
            
                guard let sself = self else { return }
            
                sself.view.setLoadingState(!(receivedFriends.count < Constants.pageSize))

                guard receivedFriends.count > 0 else { return }
                var indexPaths: [NSIndexPath] = []
                for i in 0..<receivedFriends.count {
                    indexPaths.append(NSIndexPath(forRow: sself.friends.count + i, inSection: 0))
                }
                sself.friends.appendContentsOf(receivedFriends)
                sself.view.reloadIndexPaths(indexPaths, animation: UITableViewRowAnimation.Bottom)

           }, onError: { (error) in
                self.view.setLoadingState(false)
           }, onCompleted: {
                    
           }, onDisposed: {
                    
           })
          .addDisposableTo(self.disposeBag)
    }
}



extension SearchPresenter: TableViewProtocol {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResultCell", forIndexPath: indexPath)
        
        let friend = self.friends[indexPath.row]
        cell.textLabel?.text = friend.fullName
        return cell
    }
    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row == self.friends.count - 1 {
//            self.loadFriends()
//        }
//    }
    
}

extension UISearchBar {
    
    var rx_active: ControlProperty<Bool> {
        
        let observable = Observable.deferred { () -> Observable<Bool> in
            return Observable.create({ (observer: AnyObserver<Bool>) -> Disposable in
                
                return AnonymousDisposable.init({ 
                    rx_debug("Disposed")
                })
            })
        }
        
        let binding: UIBindingObserver<UISearchBar, Bool> = UIBindingObserver(UIElement: self) { (searchBar, isActive) in
            if isActive {
                self.becomeFirstResponder()
            } else {
                self.resignFirstResponder()
            }
        }
        
        return ControlProperty(values: observable, valueSink: binding)
        
    }
}