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
    
    typealias Result = Swift.Result<[FeedImageComment], Swift.Error>
    
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
    
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: baseURL) {
            result in
            switch result {
            case .success((let data, let response)):
                if let imageComments = try? RemoteCommentsFeedLoader.map(data: data, response: response) {
                    completion(.success(imageComments))
                } else {
                    completion(.failure(Error.invalidData))
                }
            case .failure(let error as NSError) where error.domain == "offline":
                completion(.failure(Error.connectivity))
            default:
                completion(.failure(Error.invalidData))
            }
        }
    }
    
    private static var HTTP_OK: Int {
        200
    }
    
    private static func map(data: Data, response: HTTPURLResponse) throws -> [FeedImageComment] {
        guard response.statusCode == HTTP_OK else { throw Error.invalidData }
        if let data = try? JSONDecoder().decode(Root.self, from: data) {
            return data.items.map({ $0.commentItem })
        }
        throw Error.invalidData
    }
    
    private struct Root: Decodable {
        let items: [RootItem]
    }
    
    private struct RootItem: Decodable {
        let id: UUID
        let message: String
        let createdAt: Date
        let author: RootItemAuthor
        
        enum CodingKeys: String, CodingKey {
            case id
                , message
                , author
            
            case createdAt = "created_at"
        }
        
        var commentItem: FeedImageComment {
            FeedImageComment(
                id: self.id,
                message: self.message,
                createdAt: self.createdAt,
                author: self.author.commentAuthor)
        }
    }
    
    private struct RootItemAuthor: Decodable {
        let username: String
        
        var commentAuthor: FeedImageCommentAuthor {
            FeedImageCommentAuthor(username: self.username)
        }
    }
}

struct FeedImageComment: Equatable {
    let id: UUID
    let message: String
    let createdAt: Date
    let author: FeedImageCommentAuthor
}

struct FeedImageCommentAuthor: Equatable {
    let username: String
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
        
        expect(sut, expectedResult: .failure(SUTError.invalidData)) {
            client.complete(data: json)
        }
    }
    
    func test_offlineLoad_deliversConnectivityError() {
        let (sut, client) = makeSUT()
        
        expect(sut, expectedResult: .failure(SUTError.connectivity)) {
            client.completeAsOffline()
        }
    }
    
    func test_load_emptyItemsResponseRetreivesEmptyArray() {
        let (sut, client) = makeSUT()
        let emptyJSON = makeEmptyItemsJSON()
        
        expect(sut, expectedResult: .success([])) {
            client.complete(data: emptyJSON)
        }
    }
    
    // MARK: Helpers
    private func makeEmptyItemsJSON() -> Data {
        Data("{\"items\":[]}".utf8)
    }
    
    private func makeInvalidJSON() -> Data {
        Data("invalid JSON".utf8)
    }
    
    private func expect(_ sut: RemoteCommentsFeedLoader, expectedResult: RemoteCommentsFeedLoader.Result, action: @escaping () -> Void, file: StaticString = #file, line: UInt = #line) {
        sut.load { result in
            switch (result, expectedResult) {
            case (.success(let resultItems), .success(let expectedItems)):
                XCTAssertEqual(resultItems, expectedItems, file: file, line: line)
            case (.failure(let resultError), .failure(let expectedError)):
                XCTAssertEqual(resultError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Not expected state, received result: \(result) expected result: \(expectedResult)", file: file, line: line)
            }
        }
        action()
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
