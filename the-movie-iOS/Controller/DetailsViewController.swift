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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    guard let movieDetail = movieDetail else{return}
    
    //Populate the elements with the data from ViewController
    titleLabel.text = movieDetail.title
    guard let posterPath = movieDetail.posterPath else{return}
    titlePoster.load(url: URL(string: Constants.baseImageURL + posterPath)!)
    movieOverview.text = movieDetail.overview
    guard let oTitle = movieDetail.originalTitle else {
      return originalTitle.text = "TBA"
    }
    originalTitle.text = "Original Title : " + oTitle
    guard let rating = movieDetail.voteAverage else {
      return userRating.text = "TBA"
    }
    userRating.text = String(rating) + "/10"
    releaseYear.text = String(movieDetail.releaseDate ?? "TBA")
    
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */
}
