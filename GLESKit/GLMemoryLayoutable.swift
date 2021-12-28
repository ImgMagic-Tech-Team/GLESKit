//
//  VertexBufferObjectLayoutable.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

/// <#Description#>
public protocol GLMemoryLayoutable {
    static var memorySize: Int { get }
    var primitiveSequence: [GLfloat] { get }
}

// MARK: - <#GLVertexBufferObjectMemoryLayoutable#>
extension Float: GLMemoryLayoutable {
    
    /// <#Description#>
    public static var memorySize: Int {
        return MemoryLayout<Float>.size
    }
    
    /// <#Description#>
    public var primitiveSequence: [GLfloat] {
        return [self]
    }
}

// MARK: - <#GLVertexBufferObjectMemoryLayoutable#>
extension GLKVector2: GLMemoryLayoutable {
    
    /// <#Description#>
    public static var memorySize: Int {
        return MemoryLayout<GLKVector2>.size
    }
    
    /// <#Description#>
    public var primitiveSequence: [GLfloat] {
        return [self.x, self.y]
    }
}

// MARK: - <#GLVertexBufferObjectMemoryLayoutable#>
extension GLKVector3: GLMemoryLayoutable {
    
    /// <#Description#>
    public static var memorySize: Int {
        return MemoryLayout<GLKVector3>.size
    }
    
    /// <#Description#>
    public var primitiveSequence: [GLfloat] {
        return [self.x, self.y, self.z]
    }
}

// MARK: - <#GLVertexBufferObjectMemoryLayoutable#>
extension GLKVector4: GLMemoryLayoutable {
    
    /// <#Description#>
    public static var memorySize: Int {
        return MemoryLayout<GLKVector4>.size
    }
    
    /// <#Description#>
    public var primitiveSequence: [GLfloat] {
        return [self.x, self.y, self.z, self.w]
    }
}

