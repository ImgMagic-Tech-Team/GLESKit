//
//  VertexArray.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

/// <#Description#>
///
/// - sizeMismatch: <#sizeMismatch description#>
enum GLVertexArrayError: Error {
    case sizeMismatch(details: String)
}

/// <#Description#>
public class GLVertexArray<VertexType: GLVertex>: GLObject, GLObjectUsable {
    
    /// <#Description#>
    internal var vertices: [VertexType]
    
    /// <#Description#>
    internal var indices: [GLushort]
    
    /// <#Description#>
    private let vertexDataBuffer: GLuint
    
    /// <#Description#>
    private let vertexIndicesBuffer: GLuint
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - vertices: <#vertices description#>
    ///   - indices: <#indices description#>
    /// - Throws: <#throws value description#>
    public init(vertices: [VertexType], indices: [GLushort]) throws {
        
        // Generate GL objects
        var arrayName: GLuint = 0
        glGenVertexArrays(1, &arrayName)
        glBindVertexArray(arrayName)
        
        var dataBuffer: GLuint = 0
        var indicesBuffer: GLuint = 0
        
        glGenBuffers(1, &dataBuffer)
        glGenBuffers(1, &indicesBuffer)
        
        vertexDataBuffer = dataBuffer
        vertexIndicesBuffer = indicesBuffer
        
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexDataBuffer)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), vertexIndicesBuffer)
        
        // init buffers
        self.vertices = vertices
        self.indices = indices
        
        let verticesPrimitiveSequence = vertices.flatMap({ $0.primitiveSequence })
        
        glBufferData(GLenum(GL_ARRAY_BUFFER),
                     MemoryLayout<GLfloat>.size * verticesPrimitiveSequence.count,
                     verticesPrimitiveSequence,
                     GLenum(GL_DYNAMIC_DRAW))
        
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER),
                     MemoryLayout<GLushort>.size * indices.count,
                     indices,
                     GLenum(GL_STATIC_DRAW))
        
        var offset = 0
        for layout in VertexType.attributeLayouts {
            glEnableVertexAttribArray(GLuint(layout.location))
            glVertexAttribPointer(GLuint(layout.location), GLint(layout.memorySize / MemoryLayout<GLfloat>.size), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(VertexType.memorySize), UnsafeRawPointer(bitPattern: offset));
            offset += layout.memorySize
        }
        
        try super.init(name: arrayName)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - position: <#position description#>
    ///   - vertices: <#vertices description#>
    /// - Throws: <#throws value description#>
    public func replaceVertex(at position: Int,
                              with vertices: [VertexType]) throws {
        
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - range: <#range description#>
    ///   - vertices: <#vertices description#>
    /// - Throws: <#throws value description#>
    public func replaceVertices(in range: ClosedRange<Int>,
                                with vertices: [VertexType]) throws {
        guard range.count == vertices.count else {
            throw GLVertexArrayError.sizeMismatch(details: "Size of the range (\(range.count)) doesn't match the amount of vertices (\(vertices.count))")
        }
        
        guard vertices.count > 0 else {
            return
        }
        self.vertices.replaceSubrange(range, with: vertices)
        
        //let vertex = vertices.first!
        //glBufferSubData(GLenum(GL_ARRAY_BUFFER), range.lowerBound * vertex.memorySize,
        //                range.count * vertex.memorySize, vertices.flatMap { $0.decomposed })
    }
    
    deinit {
        glDeleteVertexArrays(1, &name)
        glDeleteBuffers(1, [vertexDataBuffer, vertexIndicesBuffer])
    }
    
    
    /// <#Description#>
    public func use() {
        glBindVertexArray(name)
    }
    
}
