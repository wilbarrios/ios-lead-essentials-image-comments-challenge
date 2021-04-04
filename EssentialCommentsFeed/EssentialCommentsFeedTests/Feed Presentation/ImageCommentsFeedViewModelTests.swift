//
//  ImageCommentsFeedViewModelTests.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation
import XCTest
@testable import EssentialCommentsFeed

public final class ImageCommentsViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    public static var title: String {
        return R.ImmageCommentsFeed.title
    }
    
    private let loader: ImageCommentsLoader
    
    var onLoadingStateChange: Observer<Bool>?
    var onErrorStateChange: Observer<String>?
    
    init(loader: ImageCommentsLoader) {
        self.loader = loader
    }
    
    func load() {
        onLoadingStateChange?(true)
        loader.load { [weak self] result in
            self?.onLoadingStateChange?(false)
            switch result {
            default:
                self?.onErrorStateChange?(R.ImmageCommentsFeed.loadError)
            }
        }
    }
}

public protocol ImageCommentsLoader {
    typealias Result = Swift.Result<[FeedImageComment], Error>
    
    @discardableResult
    func load(completion: @escaping (Result) -> Void) -> LoaderTask
}

class ImageCommentsFeedViewModelTests: XCTestCase {
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
    
    // MARK: Helpers
    private func makeAnyError() -> NSError {
        NSError(domain: "any", code: 1)
    }
    
    private func bind(_ sut: ImageCommentsViewModel, file: StaticString = #file, line: UInt = #line) -> ViewMock {
        let v = ViewMock()
        sut.onLoadingStateChange = v.loadingStateChange
        sut.onErrorStateChange = v.errorMessageStateChange
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
//        let bundle = Bundle(for: ImageCommentsViewModel.self)
        let bundle = Bundle(for: R.self)
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
        
        var messagesCount: Int {
            messages.count
        }
        
        func load(completion: @escaping (Result) -> Void) -> LoaderTask {
            messages.append(completion)
            return LoaderTaskMock()
        }
        
        func complete(result: Result? = nil, _ index: Int = 0) {
            let _result = result ?? makeSuccessResult()
            messages[index](_result)
        }
        
        private func makeSuccessResult() -> Result {
            .success([])
        }
    }
    
    private class LoaderTaskMock: LoaderTask {
        var isCanceled: Bool = false
        func cancel() {
            isCanceled = true
        }
    }
    
    private class ViewMock {
        var isLoading: Bool?
        var errorMessage: String?
        
        func loadingStateChange(_ isLoading: Bool) {
            self.isLoading = isLoading
        }
        
        func errorMessageStateChange(_ errorMessage: String) {
            self.errorMessage = errorMessage
        }
    }
}
