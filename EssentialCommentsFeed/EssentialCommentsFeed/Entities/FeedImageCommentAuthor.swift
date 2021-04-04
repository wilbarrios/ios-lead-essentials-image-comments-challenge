//
//  FeedImageCommentAuthor.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation

public struct FeedImageCommentAuthor: Equatable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
}
