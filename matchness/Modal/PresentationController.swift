//
//  PresentationController.swift
//  ccc
//
//  Created by 中村篤史 on 2020/09/26.
//

import UIKit

class PresentationController: UIPresentationController {
    // 呼び出し元のView Controller の上に重ねるオーバレイView
    var overlayView = UIView()
    var parentSize_height = 2.2
    // 表示トランジション開始前に呼ばれる
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        overlayView.frame = containerView.bounds
        overlayView.gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(PresentationController.overlayViewDidTouch(_:)))]
        overlayView.backgroundColor = .black
        overlayView.alpha = 0.0
        containerView.insertSubview(overlayView, at: 0)

        // トランジションを実行
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.7
            }, completion:nil)

        if UIScreen.main.nativeBounds.height >= 1792 {
            self.parentSize_height = 2.1
        } else {
            self.parentSize_height = 1.7
        }
    }

    // 非表示トランジション開始前に呼ばれる
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: {[weak self] context in
            self?.overlayView.alpha = 0.0
            }, completion:nil)
    }

    // 非表示トランジション開始後に呼ばれる
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            overlayView.removeFromSuperview()
        }
    }

//    let margin = (x: CGFloat(30), y: CGFloat(220.0))
//    // 子のコンテナサイズを返す
//    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
//        return CGSize(width: parentSize.width - margin.x, height: parentSize.height - margin.y)
//    }
//
//    // 呼び出し先のView Controllerのframeを返す
//    override var frameOfPresentedViewInContainerView: CGRect {
//        var presentedViewFrame = CGRect()
//        let containerBounds = containerView!.bounds
//        let childContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
//        presentedViewFrame.size = childContentSize
//        presentedViewFrame.origin.x = margin.x / 2
//        presentedViewFrame.origin.y = margin.y / 2
//
//        return presentedViewFrame
//    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        .init(width: parentSize.width / 1.2, height: parentSize.height / CGFloat(self.parentSize_height))
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerViewBounds = containerView?.bounds else { return .zero }

        var frame = CGRect.zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)

        frame.origin.x = (containerViewBounds.size.width - frame.size.width) / 2
        frame.origin.y = (containerViewBounds.size.height - frame.size.height) / 3

        return frame
    }
    
    
    // レイアウト開始前に呼ばれる
    override func containerViewWillLayoutSubviews() {
        overlayView.frame = containerView!.bounds
        presentedView?.frame = frameOfPresentedViewInContainerView
        presentedView?.layer.cornerRadius = 10
        presentedView?.clipsToBounds = true
    }

    // レイアウト開始後に呼ばれる
    override func containerViewDidLayoutSubviews() {
    }

    // overlayViewをタップした時に呼ばれる
    @objc func overlayViewDidTouch(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
