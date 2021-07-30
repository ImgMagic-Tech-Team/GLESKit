//
//  Object.swift
//  GLESKit
//
//  Created by SuXinDe on 2020/1/22.
//  Copyright © 2020 su xinde. All rights reserved.
//

import Foundation
import GLKit

/// <#Description#>
open class GLObject {
    
    /// <#Description#>
    var name: GLuint
    
    /// <#Description#>
    ///
    /// - Parameter name: <#name description#>
    /// - Throws: <#throws value description#>
    init(name: GLuint) throws {
        if name == 0 {
            let errMsg = "Make sure your GL context has been successfully set up"
            throw GLObject.ObjectError.unableToCreate(suggestion: errMsg)
        }
        self.name = name
    }
    
    public enum ObjectError: Error {
        case unableToCreate(suggestion: String)
    }
    
    
    /// <#Description#>
    ///
    /// - invalidSize: <#invalidSize description#>
    public enum SizeError: Error {
        case invalidSize(details: String)
    }
  
}

/// <#Description#>
internal protocol GLObjectUsable {
    func use()
}


extension GLKView: GLObjectUsable {
    func use() {
        bindDrawable()
    }
}




/// <#Description#>
internal protocol GLObjectSizeable {
    var size: CGSize { get }
    func validate(size: CGSize) throws
}

// MARK: - <#Description#>
internal extension GLObjectSizeable {
    func validate(size: CGSize) throws {
        if size.width == 0 || size.height == 0 {
            throw GLObject.SizeError.invalidSize(details: "Size cannot have dimensions of 0")
        }
    }
}

// MARK: - <#GLObjectSizeable#>
extension UIView: GLObjectSizeable {
    var size: CGSize {
        return bounds.size
    }
}

