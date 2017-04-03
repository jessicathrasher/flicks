//
//  DetailViewController.swift
//  flicks
//
//  Created by Jessica Thrasher on 3/31/17.
//  Copyright © 2017 Cisco. All rights reserved.
//

import UIKit
import AFNetworking



class DetailViewController: UIViewController {

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let overview = movie["overview"] as? String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            let baseURL = "https://image.tmdb.org/t/p/w500"
            let fullSizeBaseURL = "https://image.tmdb.org/t/p/original"

            let imageRequest = URLRequest(url: URL(string: baseURL + posterPath)!)
            let fullSizeImageRequest = URLRequest(url: URL(string: fullSizeBaseURL + posterPath)!)

            posterImageView.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    self.posterImageView.image = image

                    // After loading smaller res image - replace with full size
                    self.posterImageView.setImageWith(
                        fullSizeImageRequest,
                        placeholderImage: nil,
                        success: { (imageRequest, imageResponse, image) -> Void in

                            self.posterImageView.image = image
                    },
                        failure: { (imageRequest, imageResponse, error) -> Void in
                            // do something for the failure condition
                    })
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })

        }
        
        infoView.backgroundColor = Config.flicksDarkGreenColor

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 

}
