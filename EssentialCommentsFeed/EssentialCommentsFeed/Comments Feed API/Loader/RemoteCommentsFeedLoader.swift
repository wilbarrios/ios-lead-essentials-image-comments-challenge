//
//  RemoteCommentsFeedLoader.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation

final public class RemoteCommentsFeedLoader: ImageCommentsLoader {
    
    public typealias Result = Swift.Result<[FeedImageComment], Swift.Error>
    
    private let baseURL: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.baseURL = url
        self.client = client
    }
    
    @discardableResult
    public func load(completion: @escaping (Result) -> Void) -> LoaderTask {
        let httpClientTask = client.get(from: baseURL) {
            result in
            switch result {
            case .success((let data, let response)):
                if let imageComments = try? ImageCommentsResponseMapper.map(data: data, response: response) {
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
        return HTTPClientTaskWrapper(httpClientTask)
    }
}
