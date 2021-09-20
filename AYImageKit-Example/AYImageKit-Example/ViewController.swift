//
//  ViewController.swift
//  AYImageKit-Example
//
//  Created by Adnan Yousaf on 16/09/2021.
//

import UIKit
import AYImageKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: AYImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isCircular = true
        imageView.cacheInDisk = false
        imageView.cacheInMemory = false
        imageView.currentViewController = self
        imageView.isAllowToOpenImage = true
        imageView.isSharingEnabled = true
        imageView.isShowActivityIndicator = true
        imageView.imageContentMode = .scaleAspectFill
        imageView.isforceRemoteFetchingEnabled = false
        imageView.placeHolderImage = nil
        imageView.text = "Adnan Yousaf"
        imageView.updateStyle(with: Style(font: UIFont.systemFont(ofSize: 34), textColor: UIColor.white, background: UIColor.black, borderColor: UIColor.black))
        imageView.setImageFromUrl(url: "https://file-examples-com.github.io/uploads/2017/10/file_example_JPG_100kB")
        
    }
    
    
}

