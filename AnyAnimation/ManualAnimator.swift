//
//  ManualAnimator.swift
//  AnyAnimation
//
//  Created by Sergey Gavrilyuk on 2017-09-05.
//  Copyright © 2017 Gavrix. All rights reserved.
//

import Foundation

public class ManualAnimator: Animator {
  
  var currentAnimation: Animation?
  
  public init() {}
  
  public func run(animation: Animation) {
    self.currentAnimation = animation
    self.time = .zero
  }
  
  public var time: RelativeTimeInterval = .zero {
    didSet {
      self.currentAnimation?.tick(at: time)
    }
  }
}
