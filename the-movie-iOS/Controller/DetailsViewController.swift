//
//  DetailsViewController.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 24/11/20.
//

import UIKit

class DetailsViewController: UIViewController {
  var movieDetail: MovieData.Result?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var titlePoster: UIImageView!
  @IBOutlet weak var movieOverview: UILabel!
  @IBOutlet weak var releaseYear: UILabel!
  @IBOutlet weak var userRating: UILabel!
  @IBOutlet weak var originalTitle: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.delegate = self
    guard let movieDetail = movieDetail else{return}
    
    //Populate the elements with the data from ViewController
    movieOverview.text = movieDetail.overview
    titleLabel.text = movieDetail.title
    releaseYear.text = String(movieDetail.releaseDate ?? "TBA")
    guard let posterPath = movieDetail.posterPath else{return}
    titlePoster.kf.indicatorType = .activity
    titlePoster.kf.setImage(with: URL(string: Constants.baseImageURL + posterPath))
    guard let oTitle = movieDetail.originalTitle else {
      return originalTitle.text = "TBA"
    }
    originalTitle.text = "Original Title : " + oTitle
    guard let rating = movieDetail.voteAverage else {
      return userRating.text = "TBA"
    }
    userRating.text = String(rating) + "/10"
  }
}

extension DetailsViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.x = 0
  }
}
