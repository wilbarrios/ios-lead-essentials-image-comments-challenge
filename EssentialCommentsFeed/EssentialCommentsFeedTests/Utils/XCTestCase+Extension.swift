//
//  XCTestCase+Extension.swift
//  EssentialCommentsFeedTests
//
//  Created by Wilmer Barrios on 04/04/21.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackMemoryLeaks(_ object: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock {
            [weak object] in
            XCTAssertNil(object, "Instance did not deallocate, potential memory leak", file: file, line: line)
        }
    }
}

