//
//  UIView+BasicAnimationTweakTemplate.swift
//  SwiftTweaks
//
//  Created by Bryan Clark on 4/8/16.
//  Copyright © 2016 Khan Academy. All rights reserved.
//

import Foundation

public extension UIView {

	/// A convenience wrapper for iOS-style spring animations.
	/// Under the hood, it gets the current value for each tweak in the group, and uses that in an animation.
	public static func animateWithBasicAnimationTweakTemplate(
		_ basicAnimationTweakTemplate: BasicAnimationTweakTemplate,
		tweakStore: TweakStore,
		options: UIViewAnimationOptions,
		animations: @escaping () -> Void,
		completion: ((Bool) -> Void)?
		) {
		UIView.animate(
			withDuration: tweakStore.assign(basicAnimationTweakTemplate.duration),
			delay: tweakStore.assign(basicAnimationTweakTemplate.delay),
			options: options,
			animations: animations,
			completion: completion
		)
	}
}
