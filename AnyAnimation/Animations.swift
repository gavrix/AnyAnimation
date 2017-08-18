//
//  Animation.swift
//  Killme
//
//  Created by Sergey Gavrilyuk on 2017-08-09.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation

public class AnimatableProperty<T: Interpolatable> {
    fileprivate(set) public var value: T {
        didSet {
            didChange(value)
        }
    }
    let didChange: (T) -> Void

    init(_ value: T, didChange: @escaping (T) -> Void) {
        self.value = value
        self.didChange = didChange
    }
}



public protocol Animation {
    func tick(at time: RelativeTimeInterval)
    var duration: TimeInterval { get }
}

extension Animation {
    public func inverted() -> Animation {
        return InvertedAnimation(animation: self)
    }
}

fileprivate struct InvertedAnimation: Animation {
    let animation: Animation
    init(animation: Animation) {
        self.animation = animation
    }
    
    var duration: TimeInterval { return animation.duration }
    func tick(at time: RelativeTimeInterval) {
        animation.tick(at: time.inverted())
    }
    
}

public struct AnimationGroup: Animation {
    
    private struct LocalAnimation {
        let animation: Animation
        let durationMultiplier: TimeInterval
        
        func tick(at time: RelativeTimeInterval) {
            let localTime = RelativeTimeInterval(interval: time.value * durationMultiplier, maxInterval: 1)
            animation.tick(at: localTime)
        }
    }
    
    private let animations: [LocalAnimation]
    public let duration: TimeInterval
    
    public init(_ animations: [Animation]) {
        let maxDuration = animations.reduce(0, { max($0, $1.duration) })
        
        self.animations = animations.map { LocalAnimation(animation: $0,
                                                     durationMultiplier: maxDuration / $0.duration) }
        duration = maxDuration
    }
    
    public func tick(at time: RelativeTimeInterval) {
        for animation in animations {
            animation.tick(at: time)
        }
    }
    
}

public struct AnimationSequence: Animation {
        
    private struct LocalAnimation {
        let animation: Animation
        let startTimeOffset: RelativeTimeInterval
        let localDuration: RelativeTimeInterval
        let overallDuration: TimeInterval
        
        func tick(at time: RelativeTimeInterval) {
            guard time >= startTimeOffset, time < startTimeOffset + localDuration else { return }
            
            let localTime = RelativeTimeInterval(interval: time - startTimeOffset, maxInterval: localDuration)
            animation.tick(at: localTime)
        }
    }
    

    
    private var animations: [LocalAnimation]
    public let duration: TimeInterval
    
    public init(_ animations: [Animation]) {

        let overallDuration = animations.reduce(0, { $0 + $1.duration } )
        var startTimeOffset = RelativeTimeInterval.zero
        
        self.animations = animations.map { animation in
            let localDuration = RelativeTimeInterval(interval: animation.duration, maxInterval: overallDuration)
            let localAnimation = LocalAnimation(animation: animation,
                           startTimeOffset: startTimeOffset,
                           localDuration: localDuration,
                           overallDuration: overallDuration)
            startTimeOffset = startTimeOffset + localDuration
            return localAnimation
        }
        self.duration = overallDuration
    }
    
    public func tick(at time: RelativeTimeInterval) {
        for animation in animations {
            animation.tick(at: time)
        }
    }
}

public protocol PropertyAnimation: Animation {
    associatedtype T: Interpolatable
    
    var animatableProperty: AnimatableProperty<T> { get }
    var timingFunction: (RelativeTimeInterval) -> Float { get }
    
    func interpolatedValue(at state: Float) -> T
}

extension PropertyAnimation {
    
    public func tick(at time: RelativeTimeInterval) {
        let state = timingFunction(time)
        animatableProperty.value = interpolatedValue(at: state)
    }
}


public struct BasicAnimation<T: Interpolatable>: PropertyAnimation {

    public func interpolatedValue(at state: Float) -> T {
         return from * (1 - state) + to * state
    }

    public var timingFunction: (RelativeTimeInterval) -> Float
    public let animatableProperty: AnimatableProperty<T>
    public let duration: TimeInterval

    private let from: T
    private let to: T

    public init(from: T, to: T, on property: AnimatableProperty<T>, duration: TimeInterval) {
        self.animatableProperty = property
        self.from = from
        self.to = to
        self.duration = duration
        timingFunction = { Float($0.value) }
    }

}

extension BasicAnimation {
    public init(from: T, to: T, duration: TimeInterval, applicator: @escaping (T) -> Void) {
        self.init(from: from, to: to, on: AnimatableProperty(from, didChange: applicator), duration: duration)
    }
}




