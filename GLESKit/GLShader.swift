//
//  Shader.swift
//  GLESKit
//
//  Created by SuXinDe on 2019/7/22.
//  Copyright © 2019 su xinde. All rights reserved.
//

import UIKit
import OpenGLES


/// <#Description#>
public class GLShader: GLObject {

    
    /// <#Description#>
    public enum ShaderType {
        case vertex
        case fragment
        
        /// <#Description#>
        public var glType: GLenum {
            switch self {
            case .vertex:
                return GLenum(GL_VERTEX_SHADER)
            case .fragment:
                return GLenum(GL_FRAGMENT_SHADER)
            }
        }
    }
    
    /// <#Description#>
    ///
    /// - failedCompilation: <#failedCompilation description#>
    /// - sourceFileNotFound: <#sourceFileNotFound description#>
    public enum Err: Error {
        case failedCompilation(details: String)
        case sourceFileNotFound
    }

    
    
    /// <#Description#>
    internal let type: ShaderType
    
    /// <#Description#>
    internal let source: String
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - resourceName: <#resourceName description#>
    ///   - type: <#type description#>
    /// - Throws: <#throws value description#>
    public init(resourceName: String, type: GLShader.ShaderType) throws {
        guard let shaderSourcePath = Bundle.main.path(forResource: resourceName, ofType: nil) else {
            throw GLShader.Err.sourceFileNotFound
        }
        let source = try String(contentsOfFile: shaderSourcePath)
        let name = glCreateShader(type.glType)
        var cSource = (source as NSString).utf8String
        
        glShaderSource(name, 1, &cSource, nil)
        glCompileShader(name);
        
        var compiled: GLint = 0
        glGetShaderiv(name, GLenum(GL_COMPILE_STATUS), &compiled)
        
        if compiled == GLObject.Invalid {
            
            var infoLength: GLint = 0
            glGetShaderiv(name, GLenum(GL_INFO_LOG_LENGTH), &infoLength)
            
            var errorMessage: String = ""
            
            if infoLength > 1 {
                let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: Int(infoLength))
                glGetShaderInfoLog(name, infoLength, nil, infoLog)
                errorMessage = String(cString: infoLog)
                free(infoLog)
            }
            
            glDeleteShader(name)
            
            throw GLShader.Err.failedCompilation(details: errorMessage)
        }
        
        self.type = type
        self.source = source
        
        try super.init(name: name)
    }
    
    deinit {
        glDeleteShader(name)
    }
    
    
    
}
