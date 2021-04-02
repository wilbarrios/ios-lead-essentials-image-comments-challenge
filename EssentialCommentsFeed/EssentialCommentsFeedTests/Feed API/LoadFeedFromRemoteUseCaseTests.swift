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
    
    private let baseURL: URL
    private let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.baseURL = url
        self.client = client
    }
    
    func load() {
        client.get(from: baseURL, completion: {_ in })
    }
}

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotFetchRemoteData() {
        let client = HTTPClientMock()
        let _ = RemoteCommentsFeedLoader(url: makeAnyURL(), client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requeststGivenURL() {
        let client = HTTPClientMock()
        let expectedURL = makeAnyURL()
        let sut = RemoteCommentsFeedLoader(url: expectedURL, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, expectedURL)
    }
    
    // MARK: Helpers
    private func makeAnyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    // MARK: Testing entities
    private class HTTPClientMock: HTTPClient {
        var requestedURL: URL?
        
        // Extensions
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            requestedURL = url
            return HTTPClientTaskMock()
        }
    }
    
    private class HTTPClientTaskMock: HTTPClientTask {
        func cancel() {
            
        }
    }
}
