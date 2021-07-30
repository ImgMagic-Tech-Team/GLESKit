//
//  WavefrontFileReader.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/23.
//  Copyright © 2019 su xinde. All rights reserved.
//

import Foundation
import GLESKit

public enum ModelLoadingError: Error {
    case unreadableData(details: String)
    case invalidData(details: String)
}

internal class WavefrontFileReader {
    
    let scanner: Scanner
    let fileName: String
    let bundle: Bundle
    
    init(fileName: String, type: String, bundle: Bundle) throws {
        guard let path = bundle.path(forResource: fileName, ofType: type) else {
            throw GLResourceLoadingError.fileNotFound(fileName: fileName)
        }
        
        let url = URL(fileURLWithPath: path)
        let content = try String(contentsOf: url)
        
        scanner = Scanner(string: content)
        scanner.charactersToBeSkipped = CharacterSet.whitespaces
        
        self.fileName = fileName
        self.bundle = bundle
    }
    
    var contentAvailable: Bool {
        return !scanner.isAtEnd
    }
    
    func moveToNextLine() {
        scanner.scanUpToCharacters(from: CharacterSet.newlines, into: nil)
        scanner.scanCharacters(from: CharacterSet.whitespacesAndNewlines, into: nil)
    }
    
    func readToken(errorMessage: String = "") throws -> NSString {
        var token: NSString?
        guard scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines, into: &token) else {
            throw ModelLoadingError.unreadableData(details: errorMessage)
        }
        return token!
    }
    
    func readInt(errorMessage: String = "") throws -> Int {
        var number: Int = 0
        guard scanner.scanInt(&number) else {
            throw ModelLoadingError.unreadableData(details: errorMessage)
        }
        return number
    }
    
    func readFloat(errorMessage: String = "") throws -> Float {
        var number: Float = 0.0
        guard scanner.scanFloat(&number) else {
            throw ModelLoadingError.unreadableData(details: errorMessage)
        }
        return number
    }
    
    func skip(string: String, errorMessage: String = "") throws {
        guard scanner.scanString(string, into: nil) else {
            throw ModelLoadingError.invalidData(details: errorMessage)
        }
    }
}
