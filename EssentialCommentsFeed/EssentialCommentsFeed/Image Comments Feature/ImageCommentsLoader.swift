//
//  ImageCommentsLoader.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation

public protocol ImageCommentsLoader {
    typealias Result = Swift.Result<[FeedImageComment], Error>
    
    @discardableResult
    func load(completion: @escaping (Result) -> Void) -> LoaderTask
}
