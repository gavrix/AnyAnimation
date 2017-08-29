//
//  Created by Sergey Gavrilyuk on 2017-08-18.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import UIKit
import AnyAnimation

class ViewController: UIViewController {

    var animatingView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        animatingView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        animatingView.backgroundColor = .red
        animatingView.center = self.view.center
        self.view.addSubview(animatingView)
        
        let viewYPositionProperty = AnimatableProperty(view.center.y) { value in
            self.animatingView.center.y = value
        }
        
        var rotateAnimation = BasicAnimation(from: 0.0, to: 1.0, duration: 3.0) { (percentage: CGFloat) in
            self.animatingView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5 * percentage)
        }
        
        var moveAnimation = BasicAnimation(from: view.center.y, to: view.center.y + 100, on: viewYPositionProperty, duration: 1.5)
        
        let keyPointsAnimation = KeyPointsAnimation(initial: view.center.y + 100,
                                                   animatableProperty: viewYPositionProperty,
                                                   duration: 1.0) { builder in
                                                    
            builder.add(point: view.center.y - 10, at: 0.6, timingFunction: AnimationTiming.square)
            builder.add(point: view.center.y + 3, at: 0.85, timingFunction: AnimationTiming.square)
            builder.add(point: view.center.y, at: 1, timingFunction: AnimationTiming.square)
        }
        
        moveAnimation.timingFunction = AnimationTiming.square
        rotateAnimation.timingFunction = AnimationTiming.square
        
        LayerAnimator.sharedInstance.run(animation:
            AnimationSequence([
                AnimationGroup([rotateAnimation, moveAnimation]),
                rotateAnimation.inverted(),
                keyPointsAnimation
                ]))
        self.animatingViewXPosition.value += 100

    }
    
    lazy var animatingViewXPosition: ImplicitlyAnimatableProperty<CGFloat> = {
        return ImplicitlyAnimatableProperty(self.animatingView.center.x,
                                            animationProvider: AnimationProvider()) { [weak self] value in
                                                self?.animatingView.center.x = value
        }
    }()
    
    class AnimationProvider: ImplicitAnimationProvider {
        typealias T = CGFloat
        func animation(for property: AnimatableProperty<T>, from:T, to: T) -> Animation {
            var animation = BasicAnimation(from: from, to: to, on: property, duration: 3.0)
            animation.timingFunction = AnimationTiming.square(time:)
            return animation
        }
    }

}

