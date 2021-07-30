//
//  RenderConfiguration.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES

/// <#Description#>
public enum GLRenderBuffer {
    case color
    case depth
    case stencil
    
    /// <#Description#>
    internal var glRepresentation: Int32 {
        switch self {
        case .color: return GL_COLOR_BUFFER_BIT
        case .depth: return GL_DEPTH_BUFFER_BIT
        case .stencil: return GL_STENCIL_BUFFER_BIT
        }
    }
}

/// <#Description#>
public class GLRenderConfiguration {
    
    /// <#Description#>
    public var viewport: CGRect?
    
    /// <#Description#>
    public var buffersToClear: [GLRenderBuffer]?
}

/// <#Description#>
public class GLSinglePassRenderConfiguration<VertexType: GLVertex>: GLRenderConfiguration {
    
    /// <#Description#>
    internal(set) public var vertexArray: GLVertexArray<VertexType>
    
    /// <#Description#>
    internal(set) public var program: GLProgram
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - vertexArray: <#vertexArray description#>
    ///   - program: <#program description#>
    internal init(vertexArray: GLVertexArray<VertexType>,
                  program: GLProgram) {
        self.vertexArray = vertexArray
        self.program = program
    }
}

