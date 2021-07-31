//
//  GLQuaternion.swift
//  GLESKit
//
//  Created by SuXinDe on 2021/7/30.
//  Copyright © 2021 su xinde. All rights reserved.
//

import Foundation
import GLKit

public class GLQuaternion {
    
    // Stored properties
    
    public var w: Float
    public var x: Float
    public var y: Float
    public var z: Float
    
    // Lifecycle
    
    public init(w: Float, x: Float, y: Float, z: Float) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }
    
    //    public init(eulerAngles: GLKVector3) {
    //
    //    }
    //
    public init(rotationMatrix: GLKMatrix3) {
        // Determine which of w, x, y, or z has the largest absolute value
        let fourWSquaredMinus1 = rotationMatrix.m00 + rotationMatrix.m11 + rotationMatrix.m22
        let fourXSquaredMinus1 = rotationMatrix.m00 - rotationMatrix.m11 - rotationMatrix.m22
        let fourYSquaredMinus1 = rotationMatrix.m11 - rotationMatrix.m00 - rotationMatrix.m22
        let fourZSquaredMinus1 = rotationMatrix.m22 - rotationMatrix.m00 - rotationMatrix.m11
        
        var biggestIndex = 0
        var fourBiggestSquaredMinus1 = fourWSquaredMinus1
        
        if fourXSquaredMinus1 > fourBiggestSquaredMinus1 {
            fourBiggestSquaredMinus1 = fourXSquaredMinus1
            biggestIndex = 1
        }
        
        if fourYSquaredMinus1 > fourBiggestSquaredMinus1 {
            fourBiggestSquaredMinus1 = fourYSquaredMinus1
            biggestIndex = 2
        }
        
        if fourZSquaredMinus1 > fourBiggestSquaredMinus1 {
            fourBiggestSquaredMinus1 = fourZSquaredMinus1
            biggestIndex = 3
        }
        
        let biggestValue = sqrtf(fourBiggestSquaredMinus1 + 1.0) * 0.5
        let multiplier = 0.25 / biggestValue
        
        switch biggestIndex {
            case 0:
                w = biggestValue
                x = (rotationMatrix.m21 - rotationMatrix.m12) * multiplier
                y = (rotationMatrix.m02 - rotationMatrix.m20) * multiplier
                z = (rotationMatrix.m10 - rotationMatrix.m01) * multiplier
            case 1:
                x = biggestValue
                w = (rotationMatrix.m21 - rotationMatrix.m12) * multiplier
                y = (rotationMatrix.m10 + rotationMatrix.m01) * multiplier
                z = (rotationMatrix.m02 + rotationMatrix.m20) * multiplier
            case 2:
                y = biggestValue
                w = (rotationMatrix.m02 - rotationMatrix.m20) * multiplier
                x = (rotationMatrix.m10 + rotationMatrix.m01) * multiplier
                z = (rotationMatrix.m21 + rotationMatrix.m12) * multiplier
            case 3:
                z = biggestValue
                w = (rotationMatrix.m10 - rotationMatrix.m01) * multiplier
                x = (rotationMatrix.m02 + rotationMatrix.m20) * multiplier
                y = (rotationMatrix.m21 + rotationMatrix.m12) * multiplier
            default:
                z = 0.0
                w = 1.0
                x = 0.0
                y = 0.0
        }
    }
    
    public convenience init(axis: GLKVector3, angle: Float) {
        let sin = sinf(angle / 2.0)
        let cos = cosf(angle / 2.0)
        let normAxis = GLKVector3Normalize(axis)
        self.init(w: cos, x: sin * axis.x, y: sin * axis.y, z: sin * axis.z)
    }
    
    public convenience init(fromRotation: GLKVector3, toRotation: GLKVector3) {
        let angle = acosf(GLKVector3DotProduct(fromRotation, toRotation))
        let axis = GLKVector3CrossProduct(fromRotation, toRotation)
        self.init(axis: axis, angle: angle)
    }
    
    // MARK - Math
    
    // Static
    public static var identity: GLQuaternion {
        return GLQuaternion(w: 1.0, x: 0.0, y: 0.0, z: 0.0)
    }
    
    public static func dotProduct(first: GLQuaternion, second: GLQuaternion) -> Float {
        return first.w * second.w + first.x * second.x + first.y * second.y + first.z * second.z;
    }
    
    public static func slerp(first: GLQuaternion, second: GLQuaternion, t: Float) -> GLQuaternion {
        
        // "Cosine of the angle" between 2 GLQuaternions
        var cosOmega = GLQuaternion.dotProduct(first: first, second: second)
        var second = second
        
        if cosOmega < 0.0 {
            second.w = -second.w
            second.x = -second.x
            second.y = -second.y
            second.z = -second.z
            cosOmega = -cosOmega
        }
        
        // Interpolation parameters
        var k0: Float
        var k1: Float
        
        if cosOmega > 0.9999 {
            k0 = 1.0 - t
            k1 = t
        } else {
            // Compute the sin of the angle using the
            // trig identity sin ˆ2(omega) + cosˆ2(omega) = 1
            let sinOmega = sqrtf(1.0 - cosOmega * cosOmega)
            
            let omega = atan2f(sinOmega, cosOmega)
            let oneOverSinOmega = 1.0 / sinOmega
            
            k0 = sinf((1.0 - t) * omega) * oneOverSinOmega
            k1 = sinf(t * omega) * oneOverSinOmega
        }
        
        return GLQuaternion(
            w: first.w * k0 + second.w * k1,
            x: first.x * k0 + second.x * k1,
            y: first.y * k0 + second.y * k1,
            z: first.z * k0 + second.z * k1
        )
    }
    
    // Instance
    public var conjugate: GLQuaternion {
        return GLQuaternion(w: w, x: -x, y: -y, z: -z)
    }
    
    public var magnitude: Float {
        return sqrtf(w * w + x * x + y * y + z * z)
    }
    
    public var inverse: GLQuaternion {
        let m = magnitude
        return GLQuaternion(w: w / m, x: x / m, y: y / m, z: z / m)
    }
    
    public func exponentiated(exponent: Float) -> GLQuaternion {
        // Check for an identity GLQuaternion
        guard w >= 0.9999 else {
            return self
        }
        
        let alpha = acosf(w)
        let newAlpha = alpha * exponent
        let relation = sinf(newAlpha) / sinf(alpha)
        
        return GLQuaternion(w: cosf(newAlpha), x: x * relation, y: y * relation, z: z * relation)
    }
    
    //    public var axisAngle: GLKVector3 {
    //
    //    }
    //
    public var rotationMatrix: GLKMatrix3 {
        // Column-major order
        let m00: Float = 1.0 - 2.0 * y * y - 2.0 * z * z
        let m01: Float = 2.0 * x * y - 2.0 * w * z
        let m02: Float = 2.0 * x * z + 2.0 * w * y
        
        let m10: Float = 2.0 * x * y + 2.0 * w * z
        let m11: Float = 1.0 - 2.0 * x * x - 2.0 * z * z
        let m12: Float = 2.0 * y * z - 2.0 * w * x
        
        let m20: Float = 2.0 * x * z - 2.0 * w * y
        let m21: Float = 2.0 * y * z + 2.0 * w * x
        let m22: Float = 1.0 - 2.0 * x * x - 2.0 * y * y
        
        return GLKMatrix3(m: (m00, m01, m02, m10, m11, m12, m20, m21, m22))
    }
    //
    //    public var eulerAngles: GLKVector3 {
    //
    //    }
    
    // Operators overloading
    
    public static func *(left: GLQuaternion, right: GLQuaternion) -> GLQuaternion {
        let w = left.w * right.w - left.x * right.x - left.y * right.y - left.z * right.z;
        let x = left.w * right.x + left.x * right.w + left.y * right.z - left.z * right.y;
        let y = left.w * right.y + left.y * right.w + left.z * right.x - left.x * right.z;
        let z = left.w * right.z + left.z * right.w + left.x * right.y - left.y * right.x;
        return GLQuaternion(w: w, x: x, y: y, z: z)
    }
    
    public static func ==(left: GLQuaternion, right: GLQuaternion) -> Bool {
        let error: Float = 0.0001
        return left.w - right.w < error && left.x - right.x < error && left.y - right.y < error && left.z - right.z < error
    }
    
    public static func !=(left: GLQuaternion, right: GLQuaternion) -> Bool {
        return !(left == right)
    }
}

