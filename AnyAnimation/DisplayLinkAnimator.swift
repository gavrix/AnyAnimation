//
//  Created by Sergey Gavrilyuk on 2017-08-17.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation
import QuartzCore

@objc
public class DisplayLinkAnimator: NSObject, Animator {
    
    public static let sharedInstance = DisplayLinkAnimator()
    
    struct ErasedAnimation {
        var startTimestamp: CFTimeInterval
        var duration: CFTimeInterval
        var updateFunc: (RelativeTimeInterval) -> Void
    }
    
    private var displayLink: CADisplayLink! = nil
    private var runningAnimations = [ErasedAnimation]()
    
    override init() {
        super.init()
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkTick(displaylink:)))
        displayLink.add(to: .current, forMode: .defaultRunLoopMode)
    }
    
    public func run(animation: Animation) {
        runningAnimations.append(ErasedAnimation(
            startTimestamp: CACurrentMediaTime(),
            duration: animation.duration,
            updateFunc: animation.tick(at: ))
        )
    }
    
    @objc
    func displayLinkTick(displaylink: CADisplayLink) {
        var completed = [Int]()
        for (index, animation) in runningAnimations.enumerated() {
            let elapsed = displayLink.timestamp - animation.startTimestamp
            animation.updateFunc(RelativeTimeInterval(interval: elapsed, maxInterval: animation.duration))
            
            if elapsed > animation.duration {
                completed.append(index)
            }
        }
        completed.forEach { runningAnimations.remove(at: $0) }
    }
}
