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
    func retry()
}

class SearchPresenter: NSObject, ISearchPresenter {

    struct Constants {
        static let pageSize: Int = 20
    }
    
    private var friends: [Friend] = []
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var friendsService: IFriendsService = ServiceLocator.getService()!
    private var networkService: INetworkService = ServiceLocator.getService()!
    private weak var view: ISearchView!
    private var currentQuery: String = ""
    
    private var friendsObservable: Observable<[Friend]> = Observable.never() {
        didSet { self.getFriends() }
    }
    
    func setView(view: ISearchView) {
        self.view = view
        self.subscribe()
    }
    
    func subscribe() {
        
        self.view.searchTextObservable.subscribeNext { [weak self] (value: (index: Int, query: String)) in
            
            guard let sself = self else { return }
            
            if sself.currentQuery != value.query {
                sself.friends = []
                sself.view.reloadTableView()
            }
            sself.currentQuery = value.query
            
            if value.index == sself.friends.count - 1 || sself.friends.count == 0 {
                sself.view.setFooterState(FooterState.Info(.Loading))
                if value.query == "" {
                    sself.friendsObservable = sself.friendsService.API_fetchFriends(userId, count: Constants.pageSize, offset: sself.friends.count)
                } else {
                    sself.friendsObservable = sself.friendsService.API_searchFriends(userId, query: value.query, count: Constants.pageSize, offset: sself.friends.count)
                }
            }
            
        }.addDisposableTo(self.disposeBag)
    }
    
    func getFriends() {
        
        self.friendsObservable
            .observeOn(MainScheduler.asyncInstance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .UserInteractive))
            .subscribe(onNext: { [weak self] (receivedFriends) in
                
                guard let sself = self else { return }
                
                if receivedFriends.count < Constants.pageSize {
                    sself.view.setFooterState(FooterState.Hidden)
                } else {
                    sself.view.setFooterState(FooterState.Info(.Loading))
                }
                
                guard receivedFriends.count > 0 else { return }
                var indexPaths: [NSIndexPath] = []
                for i in 0..<receivedFriends.count {
                    indexPaths.append(NSIndexPath(forRow: sself.friends.count + i, inSection: 0))
                }
                sself.friends.appendContentsOf(receivedFriends)
                sself.view.reloadIndexPaths(indexPaths, animation: UITableViewRowAnimation.Bottom)
                
                }, onError: { (error) in
                    self.view.setFooterState(FooterState.Info(.Error))
                }, onCompleted: {
                    if self.friends.count == 0 {
                        self.view.setFooterState(FooterState.NoMatchingResult)
                    }
                }, onDisposed: {
                    rx_debug("Disposed")
            })
            .addDisposableTo(self.disposeBag)
    }
    
    func retry() {
        self.view.setFooterState(FooterState.Info(.Loading))
        self.getFriends()
    }
}

extension SearchPresenter: UITableViewDataSource {
    
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
}