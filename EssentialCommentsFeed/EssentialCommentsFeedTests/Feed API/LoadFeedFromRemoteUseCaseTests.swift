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
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requeststGivenURL() {
        let expectedURL = makeAnyURL()
        let (sut, client) = makeSUT(url: expectedURL)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, expectedURL)
    }
    
    // MARK: Helpers
    private func makeSUT(url: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteCommentsFeedLoader, client: HTTPClientMock) {
        let client = HTTPClientMock()
        let sut = RemoteCommentsFeedLoader(url: url ?? makeAnyURL(), client: client)
        trackMemoryLeaks(client, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func trackMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {
            [weak object] in
            XCTAssertNil(object, "Instance did not deallocate, potential memory leak", file: file, line: line)
        }
    }
    
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
