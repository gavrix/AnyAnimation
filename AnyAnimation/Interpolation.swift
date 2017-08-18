//
//  Interpolation.swift
//  Killme
//
//  Created by Sergey Gavrilyuk on 2017-08-17.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation


public protocol Interpolatable {
    static func *(lhs: Self, rhs: Float) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Int : Interpolatable {
    public static func *(lhs: Int, rhs: Float) -> Int {
        return Int(Float(lhs) * rhs)
    }
}

extension CGFloat : Interpolatable {
    public static func *(lhs: CGFloat, rhs: Float) -> CGFloat {
        return lhs * CGFloat(rhs)
    }
}
