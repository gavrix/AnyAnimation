//
//  ViewController.swift
//  AnyAnimationTestbed
//
//  Created by Sergey Gavrilyuk on 2017-08-18.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import UIKit
import AnyAnimation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        view.backgroundColor = .red
        view.center = self.view.center
        self.view.addSubview(view)
        
        var rotateAnimation = BasicAnimation(from: 0, to: 100, duration: 3.0) { value in
            let percentage = CGFloat(Double(value) / 100.0)
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5 * percentage)
        }
        
        var moveAnimation = BasicAnimation(from: view.center.y, to: view.center.y + 100, duration: 1.5) { value in
            view.center.y = value
        }
        
        moveAnimation.timingFunction = AnimationTiming.square
        rotateAnimation.timingFunction = AnimationTiming.square
        
        LayerAnimator.sharedInstance.run(animation:
            AnimationSequence([
                AnimationGroup([rotateAnimation, moveAnimation]),
                rotateAnimation.inverted()
                ]))

    }



}

