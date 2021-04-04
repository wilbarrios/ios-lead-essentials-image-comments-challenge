//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 02/04/21.
//

import Foundation
import XCTest
import EssentialCommentsFeed

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
    
    func test_loadWithNotSuccessHTTPStatusCode_deliversInvalidDataError() {
        let (sut, client) = makeSUT()
        let json = makeEmptyItemsJSON()
        
        [100, 201, 202, 300, 301, 304, 400, 403, 404, 500].enumerated().forEach({
            (i, invalidStatusCode) in
            expect(sut, expectedResult: .failure(SUTError.invalidData)) {
                client.complete(statusCode: invalidStatusCode, data: json, i)
            }
        })
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
    
    func test_load_validDataRetrivesExpectedItemsData() {
        let (sut, client) = makeSUT()
        
        let comment1 = makeComment(
            message: "Comment One",
            author: "Author One",
            createdAt: "2020-05-20T11:24:59+0000")
        let comment2 = makeComment(
            message: "Comment Two",
            author: "Author Two",
            createdAt: "2020-05-19T14:23:53+0000")
        
        let responseData = makeResponseData(comments: [comment1.json, comment2.json])
        
        expect(sut, expectedResult: .success([comment1.data, comment2.data])) {
            client.complete(data: responseData)
        }
    }
    
    func test_cancelTask_doesNotCompleteCommentsLoad() {
        let (sut, client) = makeSUT()
        let exp = expectation(description: "Wouldn't complete!")
        exp.isInverted = true
        
        let task = sut.load(completion: { _ in exp.fulfill() })
        task.cancel()
        client.complete()
        
        wait(for: [exp], timeout: 0.1)
    }
    
    // MARK: Helpers
    private func makeComment(message: String, author: String, createdAt: String) -> (json: [String: Any], data: FeedImageComment) {
        let author = makeAuthor(username: author)
        let id = makeUniqueId()
        let json: [String: Any] =
             [
                "id": id.string,
                "message": message,
                "created_at": createdAt,
                "author": author.json
             ]
        let data = FeedImageComment(id: id.data, message: message, createdAt: ISO8601DateFormatter().date(from: createdAt)!, author: author.data)
        return (json, data)
    }
    
    private func makeAuthor(username: String) -> (json: [String: Any], data: FeedImageCommentAuthor) {
        let json = ["username": username]
        let data = FeedImageCommentAuthor(username: username)
        return (json, data)
    }
    
    private func makeUniqueId() -> (data: UUID, string: String) {
        let data = UUID()
        return (data, data.uuidString)
    }
    
    private func makeResponseData(comments: Array<[String: Any]>) -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": comments])
    }
    
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
        
        var cancelledRequests = [URL]()
        
        private typealias Result = HTTPClient.Result
        private typealias CompletionHanlder = (Result) -> Void
        private var messages = [(url: URL, completion: CompletionHanlder)]()
        
        // Extensions
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return HTTPClientTaskMock(cancelCallback: { [weak self] in self?.cancelledRequests.append(url) })
        }
        
        func complete(statusCode: Int = 200, data: Data = Data(), _ index: Int = 0) {
            guard isNotCancelled(index) else { return }
            let result: Result = .success((data, makeResponse(withHTTPStatusCode: statusCode)))
            messages[index].completion(result)
        }
        
        func completeAsOffline(_ index: Int = 0) {
            guard isNotCancelled(index) else { return }
            messages[index].completion(.failure(makeOfflineError()))
        }
        
        // Helpers
        private func isNotCancelled(_ index: Int) -> Bool {
            !cancelledRequests.contains(messages[index].url)
        }
        
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
        private let cancelCallback: () -> Void
        
        init(cancelCallback: @escaping () -> Void) {
            self.cancelCallback = cancelCallback
        }
        
        func cancel() {
            cancelCallback()
        }
    }
}
