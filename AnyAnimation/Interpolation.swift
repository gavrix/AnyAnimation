//
//  Interpolation.swift
//  Killme
//
//  Created by Sergey Gavrilyuk on 2017-08-17.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation

public protocol Interpolatable {
    func interpolate(to: Self, by: Float) -> Self
}

public protocol ScalarInterpolatable {
    static func *(lhs: Self, rhs: Float) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Interpolatable where Self: ScalarInterpolatable {
    public func interpolate(to finalState: Self, by percent: Float) -> Self {
        return self * (1 - percent) + finalState * percent
    }
}

extension Int : ScalarInterpolatable {
    public static func *(lhs: Int, rhs: Float) -> Int {
        return Int(Float(lhs) * rhs)
    }
}

extension CGFloat : ScalarInterpolatable {
    public static func *(lhs: CGFloat, rhs: Float) -> CGFloat {
        return lhs * CGFloat(rhs)
    }
}

extension Int: Interpolatable {}
extension CGFloat: Interpolatable {}
