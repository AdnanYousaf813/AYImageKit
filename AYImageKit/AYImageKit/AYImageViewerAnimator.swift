//
//  AYImageViewerAnimator.swift
//  AYImageKit
//
//  Created by Adnan Yousaf on 16/09/2021.
//

import UIKit

/// Implements the zoom in and zoom out transition for `ImageViewerViewController`
class AYImageViewerAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum Transition {
        case presentation, dismissal
    }
    
    /// Implements the logic for initial and final values of each transition type
    private struct TransitionValue<T> {
        
        var transition: Transition
        var dismissed: T
        var presented: T
        
        var initial: T {
            switch transition {
            case .presentation: return dismissed
            case .dismissal: return presented
            }
        }
        
        var final: T {
            switch transition {
            case .presentation: return presented
            case .dismissal: return dismissed
            }
        }
        
    }
    
    private let transition: Transition
    private let sourceImageView: UIImageView
    
    init(transition: Transition, sourceImageView: UIImageView) {
        self.transition = transition
        self.sourceImageView = sourceImageView
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch transition {
        case .presentation: return 0.4
        case .dismissal: return 0.3
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let viewKey: UITransitionContextViewKey
        let viewControllerKey: UITransitionContextViewControllerKey
        
        switch transition {
        case .presentation:
            viewKey = .to
            viewControllerKey = .to
        case .dismissal:
            viewKey = .from
            viewControllerKey = .from
        }
        
        guard let imageViewerViewController = transitionContext.viewController(forKey: viewControllerKey) as? AYImageViewerViewController,
            let imageViewerView = transitionContext.view(forKey: viewKey) else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        if transition == .presentation {
            imageViewerView.frame = transitionContext.finalFrame(for: imageViewerViewController)
            imageViewerView.layoutIfNeeded()
            containerView.addSubview(imageViewerView)
        }
        
        let sourceSnapshot = sourceImageView.snapshotView(afterScreenUpdates: false) ?? UIView()
        sourceSnapshot.isUserInteractionEnabled = false
        sourceImageView.alpha = 0
        containerView.addSubview(sourceSnapshot)
        let snapshotAlpha = TransitionValue<CGFloat>(transition: transition, dismissed: 1, presented: 0)
        
        let dimmingView = imageViewerViewController.dimmingView!
        let dimmingViewAlpha = TransitionValue<CGFloat>(transition: transition, dismissed: 0, presented: 1)
        
        let targetImageView = imageViewerViewController.imageView!
        
        let convertedSourceImageFrame = sourceImageView.convert(sourceImageView.bounds, to: targetImageView.superview)
        
        var targetImageFrame = TransitionValue<CGRect>(
            transition: transition,
            dismissed: convertedSourceImageFrame,
            presented: targetImageView.frame)
        
        let convertedTargetImageFrame = containerView.convert(targetImageView.frame, from: targetImageView.superview)
        let dismissedSnapshotFrame = containerView.convert(sourceImageView.frame, from: sourceImageView.superview)
        let presentedSnapshotFrame = containerView.convert(targetImageView.frame, from: targetImageView.superview)
        
        var snapshotFrame = TransitionValue<CGRect>(
            transition: transition,
            dismissed: dismissedSnapshotFrame,
            presented: presentedSnapshotFrame)
        
        switch sourceImageView.contentMode {
        case .scaleAspectFit:
            targetImageFrame.dismissed = scale(targetImageView.frame, to: .fit, convertedSourceImageFrame)
            snapshotFrame.presented = scale(dismissedSnapshotFrame, to: .fill, convertedTargetImageFrame)
        case .scaleAspectFill:
            targetImageFrame.dismissed = scale(targetImageView.frame, to: .fill, convertedSourceImageFrame)
            snapshotFrame.presented = scale(dismissedSnapshotFrame, to: .fit, convertedTargetImageFrame)
        default:
            // .scaleToFill doesn't need adjustment
            // other content modes are not supported
            break
        }
        
        dimmingView.alpha = dimmingViewAlpha.initial
        targetImageView.frame = targetImageFrame.initial
        sourceSnapshot.alpha = snapshotAlpha.initial
        sourceSnapshot.frame = snapshotFrame.initial
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: { [weak dimmingView, weak targetImageView, weak sourceSnapshot] in
                dimmingView?.alpha = dimmingViewAlpha.final
                targetImageView?.frame = targetImageFrame.final
                sourceSnapshot?.frame = snapshotFrame.final
            },
            completion: { [weak sourceImageView, weak sourceSnapshot] completed in
                sourceImageView?.alpha = 1
                sourceSnapshot?.removeFromSuperview()
                transitionContext.completeTransition(completed)
        })
        
        let snapshotAlphaAnimationStartTime = TransitionValue<TimeInterval>(transition: transition, dismissed: 0, presented: 0.9)
        UIView.animateKeyframes(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [],
            animations: { [weak sourceSnapshot] in
                UIView.addKeyframe(withRelativeStartTime: snapshotAlphaAnimationStartTime.final, relativeDuration: 0.1) {
                    sourceSnapshot?.alpha = snapshotAlpha.final
                }
        }, completion: nil)
        
    }
    
    private enum ScalingMode {
        case fit, fill
    }
    
    /// Converts a rect to fit or fill another rect while maintaining its aspect ratio
    private func scale(_ rect: CGRect, to scalingMode: ScalingMode, _ targetRect: CGRect) -> CGRect {
        
        let widthScale = targetRect.width / rect.width
        let heightScale = targetRect.height / rect.height
        
        let scale: CGFloat
        
        switch scalingMode {
        case .fit: scale = min(widthScale, heightScale)
        case .fill: scale = max(widthScale, heightScale)
        }
        
        let scaledWidth = rect.width * scale
        let scaledHeight = rect.height * scale
        
        let adjustedX = targetRect.minX - (scaledWidth - targetRect.width) / 2
        let adjustedY = targetRect.minY - (scaledHeight - targetRect.height) / 2
        
        return CGRect(x: adjustedX, y: adjustedY, width: scaledWidth, height: scaledHeight)
        
    }
    
}

