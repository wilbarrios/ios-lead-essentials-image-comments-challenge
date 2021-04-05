//
//  ImageCommentsFeedControllerTests.swift
//  EssentialCommentsFeediOSTests
//
//  Created by Wilmer Barrios on 05/04/21.
//

import Foundation
import XCTest

final class ImageCommentsFeedController {
    init(loader: ImageCommentsFeedControllerTests.CommentsLoaderMock) {
        
    }
}

class ImageCommentsFeedControllerTests: XCTestCase {
    
    func test_init_doesNotLoadComments() {
        let loader = CommentsLoaderMock()
        let _ = ImageCommentsFeedController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCounts, 0)
    }
    
    // MARK: Testing entities
    class CommentsLoaderMock {
        private(set) var loadCallCounts: Int = 0
    }
    
}
