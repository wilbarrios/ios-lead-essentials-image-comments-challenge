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

final class ImageCommentsFeedController: UIViewController {
    private var loader: ImageCommentsLoader?
    
    convenience init(loader: ImageCommentsLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loader?.load { _ in }
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
        
        private(set) var loadCallCounts: Int = 0
        
        func load(completion: @escaping (ImageCommentsLoader.Result) -> Void) -> LoaderTask {
            loadCallCounts += 1
            return TaskMock()
        }
        
        class TaskMock: LoaderTask {
            func cancel() {
                
            }
        }
    }
    
}
