//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 02/04/21.
//

import Foundation
import XCTest

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

class RemoteCommentsFeedLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
}

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotFetchRemoteData() {
        let client = HTTPClientMock()
        let _ = RemoteCommentsFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    // MARK: Testing entities
    private class HTTPClientMock: HTTPClient {
        var requestedURL: URL?
        
        // Extensions
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            return HTTPClientTaskMock()
        }
    }
    
    private class HTTPClientTaskMock: HTTPClientTask {
        func cancel() {
            
        }
    }
}
