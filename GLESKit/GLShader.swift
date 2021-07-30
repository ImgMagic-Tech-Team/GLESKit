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
public enum GLShaderType {
    case vertex
    case fragment
    
    /// <#Description#>
    internal var glType: GLenum {
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
public enum GLShaderError: Error {
    case failedCompilation(details: String)
    case sourceFileNotFound
}


/// <#Description#>
public class GLShader: GLObject {

    /// <#Description#>
    internal let type: GLShaderType
    
    /// <#Description#>
    internal let source: String
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - resourceName: <#resourceName description#>
    ///   - type: <#type description#>
    /// - Throws: <#throws value description#>
    public init(resourceName: String, type: GLShaderType) throws {
        guard let shaderSourcePath = Bundle.main.path(forResource: resourceName, ofType: nil) else {
            throw GLShaderError.sourceFileNotFound
        }
        let source = try String(contentsOfFile: shaderSourcePath)
        let name = glCreateShader(type.glType)
        var cSource = (source as NSString).utf8String
        
        glShaderSource(name, 1, &cSource, nil)
        glCompileShader(name);
        
        var compiled: GLint = 0
        glGetShaderiv(name, GLenum(GL_COMPILE_STATUS), &compiled)
        
        if compiled == 0 {
            
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
            
            throw GLShaderError.failedCompilation(details: errorMessage)
        }
        
        self.type = type
        self.source = source
        
        try super.init(name: name)
    }
    
    deinit {
        glDeleteShader(name)
    }
}
