//
//  HTTPClientTaskWrapper.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 03/04/21.
//

import Foundation

internal final class HTTPClientTaskWrapper {
    private let task: HTTPClientTask
    
    init(_ task: HTTPClientTask) {
        self.task = task
    }
}

extension HTTPClientTaskWrapper: LoaderTask {
    func cancel() {
        task.cancel()
    }
}
