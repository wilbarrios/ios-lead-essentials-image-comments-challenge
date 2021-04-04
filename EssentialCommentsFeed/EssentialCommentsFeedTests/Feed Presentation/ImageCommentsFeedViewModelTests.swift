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
    public static var title: String {
        return R.ImmageCommentsFeed.title
    }
    
    private let loader: ImageCommentsLoader
    
    init(loader: ImageCommentsLoader) {
        self.loader = loader
    }
}

public protocol ImageCommentsLoader {
    typealias Result = Swift.Result<[FeedImageComment], Error>
    
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
    
    // MARK: Helpers
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
    }
    
    private class LoaderTaskMock: LoaderTask {
        var isCanceled: Bool = false
        func cancel() {
            isCanceled = true
        }
    }
}
