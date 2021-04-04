//
//  ImageCommentsFeedViewModelTests.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation
import XCTest
import EssentialCommentsFeed

class ImageCommentsFeedViewModelTests: XCTestCase, ImageCommentsTest {
    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsViewModel.title, localized("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    func test_init_doesNotFetchFeed() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.messagesCount, 0)
    }
    
    func test_load_fetchsFeedWithAndStartsLoading() {
        let (sut, loader) = makeSUT()
        let v = bind(sut)
        
        sut.load()
        
        XCTAssertEqual(loader.messagesCount, 1)
        XCTAssertTrue(v.isLoading!)
    }
    
    
    func test_stopsLoading_onFeedLoadCompletion() {
        let (sut, loader) = makeSUT()
        let v = bind(sut)
        
        sut.load()
        loader.complete()
        
        XCTAssertFalse(v.isLoading!)
    }
    
    func test_loadWithError_displaysLocalizedErrorMessage() {
        let (sut, loader) = makeSUT()
        let v = bind(sut)
        
        sut.load()
        loader.complete(result: .failure(makeAnyError()))
        
        XCTAssertEqual(v.errorMessage, localized("IMAGE_COMMENTS_LOAD_ERROR"))
    }
    
    func test_loadSucceed_displayComments() {
        let (sut, loader) = makeSUT()
        let v = bind(sut)
        
        let comment1 = makeComment(
            message: "Comment One",
            author: "Author One",
            createdAt: "2020-05-20T11:24:59+0000")
        let comment2 = makeComment(
            message: "Comment Two",
            author: "Author Two",
            createdAt: "2020-05-19T14:23:53+0000")
        
        sut.load()
        loader.complete(result: .success([comment1.model, comment2.model]))
        
        XCTAssertEqual(v.comments, [comment1.model, comment2.model])
    }
    
    func test_cancelLoad_doesCancelFeedLoaderRequest() {
        let (sut, loader) = makeSUT()
        
        sut.load()
        sut.cancelLoadIfNeeded()
        
        XCTAssertTrue(loader.taskIsCancelled())
    }
    
    // MARK: Helpers
    private func makeAnyError() -> NSError {
        NSError(domain: "any", code: 1)
    }
    
    private func bind(_ sut: ImageCommentsViewModel, file: StaticString = #file, line: UInt = #line) -> ViewMock {
        let v = ViewMock()
        sut.onLoadingStateChange = v.loadingStateChange
        sut.onErrorStateChange = v.errorMessageStateChange
        sut.onFeedLoad = v.loadComments
        trackMemoryLeaks(v, file: file, line: line)
        return v
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: ImageCommentsViewModel, loader: ImageCommentsFeedLoaderMock) {
        let loader = ImageCommentsFeedLoaderMock()
        let sut = ImageCommentsViewModel(loader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsViewModel.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
    
    // MARK: Testing entities
    private class ImageCommentsFeedLoaderMock: ImageCommentsLoader {
        typealias Result = ImageCommentsLoader.Result
        private typealias CompletionHanlder = (Result) -> Void
        
        private var messages = [CompletionHanlder]()
        private var tasks = [LoaderTaskMock]()
        
        var messagesCount: Int {
            messages.count
        }
        
        func load(completion: @escaping (Result) -> Void) -> LoaderTask {
            messages.append(completion)
            let task = LoaderTaskMock()
            tasks.append(task)
            return task
        }
        
        func complete(result: Result? = nil, _ index: Int = 0) {
            let _result = result ?? makeSuccessResult()
            messages[index](_result)
        }
        
        func taskIsCancelled(_ index: Int = 0) -> Bool {
            tasks[index].isCancelled
        }
        
        private func makeSuccessResult() -> Result {
            .success([])
        }
    }
    
    private class LoaderTaskMock: LoaderTask {
        var isCancelled: Bool = false
        func cancel() {
            isCancelled = true
        }
    }
    
    private class ViewMock {
        var isLoading: Bool?
        var errorMessage: String?
        var comments: [FeedImageComment]?
        
        func loadingStateChange(_ isLoading: Bool) {
            self.isLoading = isLoading
        }
        
        func errorMessageStateChange(_ errorMessage: String) {
            self.errorMessage = errorMessage
        }
        
        func loadComments(_ comments: [FeedImageComment]) {
            self.comments = comments
        }
    }
}
