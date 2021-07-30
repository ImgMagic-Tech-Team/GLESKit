//
//  Vertex.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES

/// <#Description#>
public class GLVertexAttributeMemoryLayout {
    
    /// <#Description#>
    var location: Int
    
    /// <#Description#>
    var memorySize: Int
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - location: <#location description#>
    ///   - memorySize: <#memorySize description#>
    public init(location: Int, memorySize: Int) {
        self.location = location
        self.memorySize = memorySize
    }
}

/// <#Description#>
public protocol GLVertex: GLVertexBufferObjectMemoryLayoutable {
    
    /// <#Description#>
    static var attributeLayouts: [GLVertexAttributeMemoryLayout] { get }
}

