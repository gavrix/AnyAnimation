# AnyAnimation
Take on creating type-safe animation APIs in swift. Started with abstract definition, it has several integrations with iOS.

## Abstract
Animations are at the core of UX anticipated on any modern UI platform, and iOS is (and has been from the beginning)one the main drivers of this experience. Pioneering with animation APIs back in the days, however, lead to many outdated APIs at this point. Since swift inception there have been many attempts to transition existing animation APIs (written in objc and heavily exploiting objc runtime) into swift syntax. Resulting APIs we have by the date, however, are still far from ideal.

This project is an attempt to design animation APIs in swift — from scratch.

## Basic definitions

Animation is a process of transitioning from one state to another by calculating intermediate state, according to certain rules. There are also needs to be something that will orchestrate this transition. In a nutshell, we need these components to be defined: **state**, **state change description**, **animator**.

## AnyAnimation APIs description
`AnyAnimation` is a set of abstract protocols defining animation components and some particular implementations to showcase how APIs can be used.

### State
State here can be anything: scalar `Int` or `Float` value, `CGPath` , or even a `UIImage`. The only requirement is to be able to calculate intermediate between to final states. Protocol `Interpolatable` defines this requirement:
```
public protocol Interpolatable {
    func interpolate(to: Self, by: Float) -> Self
}
```

For scalar values interpolation is expressed as `inital * (1 - percent) + final * percent`, which can be expressed in swift as:
```
public protocol ScalarInterpolatable {
    static func *(lhs: Self, rhs: Float) -> Self
    static func +(lhs: Self, rhs: Self) -> Self
}

extension Interpolatable where Self: ScalarInterpolatable {
    public func interpolate(to finalState: Self, by percent: Float) -> Self {
        return self * (1 - percent) + finalState * percent
    }
}
```

### State change description
Basically, it is our animation. It's exactly what `CAAnimation` and it's implementations are. It's a description of how we should perform transition. On higher level, however, it doesn't even matter how exactly transition is being performed. The only thing that matters: **percentage**, intermediate position between initial and final states. This percentage is represented as `RelativeTimeInterval` — utility type that wraps `Float` is guaranteed (based on how it's constructed) to aways be in the range [0, 1].
Another important aspect of the animation is it's **duration**, since animator needs to know how to translate absolute time that has passed since given animation started into **percentage**. That's all for abstract `Animation` definition:
```
public protocol Animation {
    func tick(at time: RelativeTimeInterval)
    var duration: TimeInterval { get }
}
```

More concrete `Animation` implementation are sound with QuartzCore animation's classes hierarchy: 

- **`Animation`** _defines **duration** and **tick()**_
    - **`AnimationSequence`** _synchronizes animations in parallel_
    - **`AnimationGroup`** _synchronizes animations in sequence_
    - **`PropertyAnimation`** _abstract, defines **animatable property** and **timing function**_
        - **`BasicAnimation`** _defines linear interpolation between **initial** and **final**_

Animatable property is basically an observable property that `PropertyAnimation` can modify and be sure that owner of that property was notified about the change.

### Animator
Animator is an entity that controls the animation transition process. It's an animation engine. In most animation APIs available on iOS this entity is abstracted away and hidden. Thus, we only add animations to `CALayer` and have no idea _who_ calculates interpolated values between animation frames, we only see that those values change on `presentationLayer`. Or, when we add `SKAction`s to `SKNode` we don't know who calculate and apply interpolated values to owning node. 

In essence, animator should be able run animation by calling `tick(at:)` with animation state. It's up to particular `Animator` implementation when to do animation tick, but it should be able to start processing animation:
```
public protocol Animator {
    func run(animation: Animation)
}
```

`AnyAnimation` comes with 3 different `Animator` implementations depending on different timing-related technologies available on iOS: 
- SpriteKit (`SKAnimator`)
- DisplayLink (`DisplayLinkAnimator`)
- CALayer (`LayerAnimator`)

All these animators are substitutable, animation's behavior should not depend on animator implementation.

# Usage
`AnyAnimation` APIs usage is similar to that of `SpriteKit`:
```
var rotateAnimation = BasicAnimation(from: 0.0, to: 1.0, duration: 3.0) { (percentage: CGFloat) in
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

```

