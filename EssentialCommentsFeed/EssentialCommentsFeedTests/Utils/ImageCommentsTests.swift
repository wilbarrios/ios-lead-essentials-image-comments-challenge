//
//  ImageCommentsTests.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation
import XCTest
import EssentialCommentsFeed

protocol ImageCommentsTest: XCTestCase { }

extension ImageCommentsTest {
    func makeAuthor(username: String) -> (json: [String: Any], model: FeedImageCommentAuthor) {
        let json = ["username": username]
        let data = FeedImageCommentAuthor(username: username)
        return (json, data)
    }
    
    func makeComment(message: String, author: String, createdAt: String) -> (json: [String: Any], model: FeedImageComment) {
        let author = makeAuthor(username: author)
        let id = makeUniqueId()
        let json: [String: Any] =
             [
                "id": id.string,
                "message": message,
                "created_at": createdAt,
                "author": author.json
             ]
        let data = FeedImageComment(id: id.data, message: message, createdAt: ISO8601DateFormatter().date(from: createdAt)!, author: author.model)
        return (json, data)
    }
}
