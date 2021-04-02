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
    
    enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    init(url: URL, client: HTTPClient) {
        self.baseURL = url
        self.client = client
    }
    
    func load(completion: @escaping (Swift.Error?) -> Void) {
        client.get(from: baseURL) {
            result in
            switch result {
            case .failure(let error as NSError) where error.domain == "offline":
                completion(Error.connectivity)
            default:
                completion(Error.invalidData)
            }
        }
    }
}

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    private typealias SUTError = RemoteCommentsFeedLoader.Error
    
    func test_init_doesNotFetchRemoteData() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requeststGivenURL() {
        let expectedURL = makeAnyURL()
        let (sut, client) = makeSUT(url: expectedURL)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURL, expectedURL)
    }
    
    func test_loadInvalidJSON_deliversInvalidDataError() {
        let (sut, client) = makeSUT()
        let json = makeInvalidJSON()
        
        expect(sut, expectedError: SUTError.invalidData) {
            client.complete(data: json)
        }
    }
    
    func test_offlineLoad_deliversConnectivityError() {
        let (sut, client) = makeSUT()
        
        expect(sut, expectedError: SUTError.connectivity) {
            client.completeAsOffline()
        }
    }
    
    private func makeInvalidJSON() -> Data {
        Data("invalid JSON".utf8)
    }
    
    // MARK: Helpers
    private func expect(_ sut: RemoteCommentsFeedLoader, expectedError: Error, action: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {
        var resultErrors = [NSError]()
        sut.load { error in resultErrors.append(error! as NSError) }
        action()
        XCTAssertEqual(resultErrors, [expectedError as NSError], file: file, line: line)
    }
    
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
        var requestedURL: URL? {
            messages.last?.url
        }
        
        private typealias Result = HTTPClient.Result
        private typealias CompletionHanlder = (Result) -> Void
        private var messages = [(url: URL, completion: CompletionHanlder)]()
        
        // Extensions
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return HTTPClientTaskMock()
        }
        
        func complete(data: Data = Data(), _ index: Int = 0) {
            let result: Result = .success((data, makeResponse()))
            messages[index].completion(result)
        }
        
        func completeAsOffline(_ index: Int = 0) {
            messages[index].completion(.failure(makeOfflineError()))
        }
        
        // Helpers
        private func makeOfflineError() -> NSError {
            return NSError(domain: "offline", code: 0)
        }
        
        private func makeResponse(withHTTPStatusCode statusCode: Int = 200) -> HTTPURLResponse {
            HTTPURLResponse(url: makeAnyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        }
        
        private func makeAnyURL() -> URL {
            URL(string: "https://any-url.com")!
        }
    }
    
    private class HTTPClientTaskMock: HTTPClientTask {
        func cancel() {
            
        }
    }
}
