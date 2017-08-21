//
//  Created by Sergey Gavrilyuk on 2017-08-18.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation

public struct KeyPointsAnimation<T: Interpolatable>: PropertyAnimation {
    
    fileprivate struct NextKeyPoint {
        var point: T
        var time: Float
        var timingFunction: TimingFunction
    }
    
    fileprivate struct InterpolationSegment {
        
        let startTime: RelativeTimeInterval
        let endTime: RelativeTimeInterval
        
        let startPoint: T
        let endPoint: T
        
        var timingFunction: TimingFunction
        
        func contains(time: RelativeTimeInterval) -> Bool {
            return startTime < time && endTime >= time
        }
        
        func interpolate(at time: RelativeTimeInterval) -> T {
            let state = timingFunction(time)
            return startPoint.interpolate(to: endPoint, by: state)
        }
        
        var duration: RelativeTimeInterval {
            return endTime - startTime
        }
    }
    
    public class PointsBuilder {
        fileprivate var points: [NextKeyPoint] = []
        public func add(point: T, at time: Float, timingFunction: @escaping TimingFunction) {
            points.append(NextKeyPoint(point:point, time: time, timingFunction: timingFunction))
        }
        
        fileprivate func build(startingWith point: T) -> [InterpolationSegment] {
            var segmentStartPoint = point
            var segmentStartTime: RelativeTimeInterval = .zero
            
            
            var segments: [InterpolationSegment] = []
            
            for nextPoint in points {
                segments.append(InterpolationSegment(
                    startTime: segmentStartTime,
                    endTime: RelativeTimeInterval(interval: TimeInterval(nextPoint.time), maxInterval: 1.0),
                    startPoint: segmentStartPoint,
                    endPoint: nextPoint.point,
                    timingFunction: nextPoint.timingFunction)
                )
                segmentStartPoint = nextPoint.point
                segmentStartTime = RelativeTimeInterval(interval: TimeInterval(nextPoint.time), maxInterval: 1.0)
            }
            return segments
            
        }
    }
    
    
    public var duration: TimeInterval
    
    public var animatableProperty: AnimatableProperty<T>
    
    private var segments: [InterpolationSegment]
    private var startingPoint: T
    
    public init(initial point: T, animatableProperty: AnimatableProperty<T>, duration: TimeInterval, buildPoints: (PointsBuilder) -> Void) {
        
        let pointsBuilder = PointsBuilder()
        buildPoints(pointsBuilder)
        
        segments = pointsBuilder.build(startingWith: point)
        
        self.startingPoint = point
        self.duration = duration
        self.animatableProperty = animatableProperty
    }
  
    public func interpolatedValue(at globalTime: RelativeTimeInterval) -> T {
        for segment in segments {
            guard segment.contains(time: globalTime) else { continue }
            
            let localTime = RelativeTimeInterval(interval: globalTime - segment.startTime, maxInterval: segment.duration)
            return segment.interpolate(at: localTime)
        }
        return startingPoint
    }
    
}

