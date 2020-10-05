//
//  PhotoViewerViewController.swift
//  ChatApp
//
//  Created by sarath kumar on 22/09/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit

class PhotoViewerViewController: UIViewController {

   private let url: URL

       init(with url: URL) {
           self.url = url
           super.init(nibName: nil, bundle: nil)
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

       private let imageView: UIImageView = {
           let imageView = UIImageView()
           imageView.contentMode = .scaleAspectFit
           return imageView
       }()

       override func viewDidLoad() {
           super.viewDidLoad()
           title = "Photo"
           navigationItem.largeTitleDisplayMode = .never
           view.backgroundColor = .black
           view.addSubview(imageView)
           imageView.sd_setImage(with: url, completed: nil)
       }

       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           imageView.frame = view.bounds
       }


}
