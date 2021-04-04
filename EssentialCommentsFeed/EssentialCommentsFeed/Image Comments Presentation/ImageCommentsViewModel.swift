//
//  ImageCommentsViewModel.swift
//  EssentialCommentsFeed
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation

public final class ImageCommentsViewModel {
    
    public typealias Observer<T> = (T) -> Void
    
    public static var title: String {
        return R.ImmageCommentsFeed.title
    }
    
    private let loader: ImageCommentsLoader
    
    public var onLoadingStateChange: Observer<Bool>?
    public var onErrorStateChange: Observer<String>?
    public var onFeedLoad: Observer<[FeedImageComment]>?
    
    public init(loader: ImageCommentsLoader) {
        self.loader = loader
    }
    
    private var task: LoaderTask?
    
    public func load() {
        onLoadingStateChange?(true)
        task = loader.load { [weak self] result in
            guard let self = self else { return }
            self.onLoadingStateChange?(false)
            switch result {
            case .success(let comments):
                self.onFeedLoad?(comments)
            default:
                self.onErrorStateChange?(R.ImmageCommentsFeed.loadError)
            }
        }
    }
    
    public func cancelLoadIfNeeded() {
        task?.cancel()
    }
}
