//
//  ImageCommentsResponseMapper.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation

final internal class ImageCommentsResponseMapper {
    private typealias Error = RemoteCommentsFeedLoader.Error
    
    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    private static var HTTP_OK: Int {
        200
    }
    
    internal static func map(data: Data, response: HTTPURLResponse) throws -> [FeedImageComment] {
        guard response.statusCode == HTTP_OK,
              let data = try? decoder.decode(Root.self, from: data) else { throw Error.invalidData }
        return data.items.map({ $0.commentItem })
    }
    
    // MARK: Mapping entities
    
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
