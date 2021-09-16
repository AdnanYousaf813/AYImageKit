//
//  AYImageViewerViewController.swift
//  AYImageKit
//
//  Created by Adnan Yousaf on 16/09/2021.
//

import UIKit

public class AYImageViewerViewController: UIViewController {
    
    var image: UIImage? {
        didSet { updateImageView() }
    }
    
    var sourceImageView: UIImageView?
    public var isSharingEnabled = true {
        didSet { updateShareButton() }
    }

    @IBOutlet weak var dimmingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet var verticalImageConstraints: [NSLayoutConstraint]!
    @IBOutlet var horizontalImageConstraints: [NSLayoutConstraint]!
    private var aspectRatioConstraint: NSLayoutConstraint?
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    override public var modalPresentationStyle: UIModalPresentationStyle {
        get { return .custom }
        set { print("Customizing the presentation on \(type(of: self)) is not supported") }
    }
    
    override public var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get { return self }
        set { print("Customizing the presentation on \(type(of: self)) is not supported") }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        setupScrollView()
        updateShareButton()
    }
    
    private func setupImageView() {
        
        widthConstraint = imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        heightConstraint = imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewDoubleTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        
        updateImageView()
        
    }
    
    private func updateImageView() {
        
        imageView?.image = image
        self.aspectRatioConstraint?.isActive = false
        self.aspectRatioConstraint = nil
        
        guard let imageView = imageView, let image = image else { return }
        
        let imageAspectRatio = image.size.ratio
        let aspectRatioConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageAspectRatio)
        aspectRatioConstraint.isActive = true
        self.aspectRatioConstraint = aspectRatioConstraint
        
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    private func updateShareButton() {
        shareButton?.isHidden = !isSharingEnabled
    }
    
    override public func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        guard let image = image else { return }
        
        let scrollAspectRatio = scrollView.frame.width / scrollView.frame.height
        let imageAspectRatio = image.size.width / image.size.height
        
        if imageAspectRatio > scrollAspectRatio {
            NSLayoutConstraint.deactivate(verticalImageConstraints + [heightConstraint])
            NSLayoutConstraint.activate(horizontalImageConstraints + [widthConstraint])
        } else {
            NSLayoutConstraint.deactivate(horizontalImageConstraints + [widthConstraint])
            NSLayoutConstraint.activate(verticalImageConstraints + [heightConstraint])
        }
        
        imageView.layoutIfNeeded()
        updateContentInset()
        
    }

    
    private func updateContentInset() {
        
        let widthSpacing = scrollView.frame.width - imageView.frame.width
        let heightSpacing = scrollView.frame.height - imageView.frame.height
        
        scrollView.contentInset.left = max(0, widthSpacing / 2)
        scrollView.contentInset.top = max(0, heightSpacing / 2)
        
    }
    
    @objc private func imageViewDoubleTapped(sender: Any) {
        
        let newZoomScale: CGFloat
            
        if scrollView.zoomScale == 1 {
            let widthScale = scrollView.frame.width / imageView.frame.width
            let heightScale = scrollView.frame.height / imageView.frame.height
            newZoomScale = max(widthScale, heightScale)
        } else {
            newZoomScale = 1
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollView.zoomScale = newZoomScale
        }
    }

    @IBAction func close(_ sender: Any) {
        presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func share(_ sender: Any) {
        guard let image = image else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
}

// MARK: - Convenience initializer
extension AYImageViewerViewController {
    
    public convenience init(image: UIImage, sourceImageView: UIImageView, isSharingEnabled: Bool) {
        let podBundle = Bundle(for: AYImageViewerViewController.self)
        self.init(nibName: "AYImageViewerViewController", bundle: podBundle)
        self.image = image
        self.isSharingEnabled = isSharingEnabled
        self.sourceImageView = sourceImageView
    }
    
}

// MARK: - Scroll view delegate
extension AYImageViewerViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
    
}

// MARK: - Transitioning delegate
extension AYImageViewerViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let sourceImageView = sourceImageView else { return nil }
        let imageViewerAnimator = AYImageViewerAnimator(transition: .presentation ,sourceImageView: sourceImageView)
        return imageViewerAnimator
        
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let sourceImageView = sourceImageView else { return nil }
        let imageViewerAnimator = AYImageViewerAnimator(transition: .dismissal ,sourceImageView: sourceImageView)
        return imageViewerAnimator
        
    }
    
}

// MARK: - Aspect Ratio
extension CGSize {
    
    public var ratio: CGFloat {
        guard width > 0, height > 0 else {
            return 1
        }
        return width / height
    }
    
}

