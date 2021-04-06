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
        let loader = CommentsLoaderMock()
        let _ = ImageCommentsFeedController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCounts, 0)
    }
    
    func test_loadAutomatically_onViewDidLoad() {
        let loader = CommentsLoaderMock()
        let sut = ImageCommentsFeedController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCounts, 1)
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
