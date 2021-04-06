//
//  ImageCommentsFeedControllerTests.swift
//  EssentialCommentsFeediOSTests
//
//  Created by Wilmer Barrios on 05/04/21.
//

import Foundation
import XCTest
import UIKit
import EssentialCommentsFeed

final class ImageCommentsFeedController: UITableViewController {
    private var loader: ImageCommentsLoader?
    
    convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        
        refresh()
    }
    
    @objc
    private func refresh() {
        self.loader?.load { [weak self] _ in self?.refreshControl?.endRefreshing() }
    }
}

class ImageCommentsFeedControllerTests: XCTestCase {
    
    func test_init_doesNotLoadComments() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCounts, 0)
    }
    
    func test_loadAutomatically_onViewDidLoad() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCounts, 1)
    }
    
    func test_load_displayLoadingState() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.refreshControl!.isRefreshing)
    }
    
    func test_loadCompletes_stopsLoadingState() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete()
        
        XCTAssertFalse(sut.refreshControl!.isRefreshing)
    }
    
    func test_pullToRefresh_loadsComments() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCounts, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCallCounts, 3)
    }
    
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsFeedController, loader: CommentsLoaderMock) {
        let loader = CommentsLoaderMock()
        let sut = ImageCommentsFeedController(loader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    // MARK: Testing entities
    class CommentsLoaderMock: ImageCommentsLoader {
        
        typealias Result = ImageCommentsLoader.Result
        private var messages = [(Result) -> Void]()
        var loadCallCounts: Int { messages.count }
        
        func complete(result: Result = .success([]), _ index: Int = 0) {
            messages[index](result)
        }
        
        // Extension
        
        func load(completion: @escaping (Result) -> Void) -> LoaderTask {
            messages.append(completion)
            return TaskMock()
        }
        
        class TaskMock: LoaderTask {
            func cancel() {
                
            }
        }
    }
    
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (target as NSObject).perform(Selector($0)) })
        })
    }
}
