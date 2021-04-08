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
    private var loaderTask: LoaderTask?
    private var tableModels = [FeedImageComment]() { didSet { tableView.reloadData() }}
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loaderTask?.cancel()
    }
    
    @objc
    private func refresh() {
        self.loaderTask = self.loader?.load { [weak self] result in
            if let items = try? result.get() {
                self?.tableModels = items
            }
            self?.refreshControl?.endRefreshing() }
    }
    
    // MARK: Extensions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModels[indexPath.row]
        let cell = ImageCommentCell()
        cell.authorLabel.text = cellModel.author.username
        cell.commentLabel.text = cellModel.message
        cell.createdAtLabel.text = cellModel.createdAt.description
        return cell
    }
}

final class ImageCommentCell: UITableViewCell {
    public let authorLabel = UILabel()
    public let commentLabel = UILabel()
    public let createdAtLabel = UILabel()
}

class ImageCommentsFeedControllerTests: XCTestCase, ImageCommentsTest {
    
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
        
        XCTAssertTrue(sut.loadIndicatorIsVisible())
    }
    
    func test_loadCompletes_stopsLoadingState() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete()
        
        XCTAssertFalse(sut.loadIndicatorIsVisible())
    }
    
    func test_pullToRefresh_loadsComments() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatesCommentsReload()
        XCTAssertEqual(loader.loadCallCounts, 2)
        
        sut.simulateUserInitiatesCommentsReload()
        XCTAssertEqual(loader.loadCallCounts, 3)
    }
    
    func test_userNavigatesBack_cancelCommentsLoad() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.simulateUserNavigatesBack()
        
        XCTAssertTrue(loader.loadWasCancelled)
    }
    
    func test_loadComments_rendersExpectedComments() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let comment = makeComment(message: "Comment One", author: "Wilmer", createdAt: isoDateOne)
        loader.complete(result: .success([comment.model]))
        
        XCTAssertEqual(sut.numberOfRenderedCommentsViews(), 1)
        
        let view = sut.getViewFor(index: 0) as? ImageCommentCell
        
        XCTAssertNotNil(view)
        XCTAssertEqual(view!.authorValue, comment.model.author.username)
        XCTAssertEqual(view!.commentValue, comment.model.message)
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
        var loadWasCancelled: Bool = false
        
        func complete(result: Result = .success([]), _ index: Int = 0) {
            messages[index](result)
        }
        
        // Extension
        
        func load(completion: @escaping (Result) -> Void) -> LoaderTask {
            messages.append(completion)
            return TaskSpy { [weak self] in self?.loadWasCancelled = true }
        }
        
        struct TaskSpy: LoaderTask {
            let cancelHandler: () -> Void
            func cancel() {
                cancelHandler()
            }
        }
    }
}

extension ImageCommentsFeedController {
    func loadIndicatorIsVisible() -> Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    func simulateUserInitiatesCommentsReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateUserNavigatesBack() {
        self.viewWillDisappear(false)
    }
    
    func getViewFor(index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    func numberOfRenderedCommentsViews() -> Int {
        tableView.numberOfRows(inSection: commentsSection)
    }
    
    private var commentsSection: Int {
        0
    }
}

private extension ImageCommentCell {
    var authorValue: String? { authorLabel.text }
    var commentValue: String? { commentLabel.text }
    var createdAtValue: String? { createdAtLabel.text }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach({ target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ (target as NSObject).perform(Selector($0)) })
        })
    }
}
