//
//  ManualAnimatorViewController.swift
//  AnyAnimationTestbed
//
//  Created by Sergey Gavrilyuk on 2017-09-05.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation
import UIKit
import AnyAnimation

class ManualAnimatorViewController: UIViewController {
  
  @IBOutlet weak var movingViewXConstraint: NSLayoutConstraint!
  @IBOutlet weak var containerView: UIView!
  
  @IBOutlet weak var movingView: UIView!
  var animator = ManualAnimator()
  
  lazy var xProperty: AnimatableProperty<CGFloat> = {
    return AnimatableProperty(self.movingViewXConstraint.constant) {
      [unowned self] in
      self.movingViewXConstraint.constant = $0
    }
  }()
  
  
  lazy var rotationProperty: AnimatableProperty<CGFloat> = {
    return AnimatableProperty(0) { [unowned self] in
      self.movingView.transform = CGAffineTransform(rotationAngle: $0)
    }
  }()
  
  @IBAction func sliderValueChanged(_ slider: UISlider) {
    self.animator.time = RelativeTimeInterval(interval: TimeInterval(slider.value), maxInterval: TimeInterval(slider.maximumValue))
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let animation =
      AnimationGroup([
        BasicAnimation(from: xProperty.value, to: containerView.frame.width - movingView.frame.width * CGFloat(0.5),
                       on: self.xProperty, duration: 1),
        BasicAnimation(from: 0, to: CGFloat.pi, on: self.rotationProperty, duration: 1)
      ])
    
    self.animator.run(animation: animation)
  }
  
}
