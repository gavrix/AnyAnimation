//
//  Created by Sergey Gavrilyuk on 2017-08-15.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation

public protocol Animator {
    func run(animation: Animation)
}


public struct RelativeTimeInterval {
    var value: TimeInterval
    public init(interval: TimeInterval, maxInterval: TimeInterval) {
        value = min(1, interval / maxInterval)
    }

    public init(interval: RelativeTimeInterval, maxInterval: RelativeTimeInterval) {
        value = interval.value / maxInterval.value
    }

    private init(value: TimeInterval) {
        self.value = value
    }
    public static let zero = RelativeTimeInterval(value: 0)
    
    public static func -(lhs: RelativeTimeInterval, rhs: RelativeTimeInterval) -> RelativeTimeInterval {
        return RelativeTimeInterval(value: lhs.value - rhs.value)
    }

    public static func +(lhs: RelativeTimeInterval, rhs: RelativeTimeInterval) -> RelativeTimeInterval {
        return RelativeTimeInterval(value: lhs.value + rhs.value)
    }

    public static func *(lhs: RelativeTimeInterval, rhs: RelativeTimeInterval) -> RelativeTimeInterval {
        return RelativeTimeInterval(value: lhs.value * rhs.value)
    }
    
    public static func >=(lhs: RelativeTimeInterval, rhs: RelativeTimeInterval) -> Bool {
        return lhs.value >= rhs.value
    }

    public static func <(lhs: RelativeTimeInterval, rhs: RelativeTimeInterval) -> Bool {
        return lhs.value < rhs.value
    }

    func inverted() -> RelativeTimeInterval {
        return RelativeTimeInterval(value: 1 - value)
    }
}

public enum AnimationTiming {
    public static func square(time: RelativeTimeInterval) -> Float {
        let twiceTime = time.value * 2
        var timingValue: Double = 0
        if twiceTime <= 1 {
            timingValue = twiceTime * twiceTime * 0.5
        } else {
            timingValue = 1 - (2 - twiceTime) * (2 - twiceTime) * 0.5
        }
        return Float(timingValue)
    }
}
