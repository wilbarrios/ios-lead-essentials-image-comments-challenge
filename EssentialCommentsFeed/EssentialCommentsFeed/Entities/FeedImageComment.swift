//
//  FeedImageComment.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation

public struct FeedImageComment: Equatable {
    public let id: UUID
    public let message: String
    public let createdAt: Date
    public let author: FeedImageCommentAuthor
    
    public init(id: UUID, message: String, createdAt: Date, author: FeedImageCommentAuthor) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }
}
