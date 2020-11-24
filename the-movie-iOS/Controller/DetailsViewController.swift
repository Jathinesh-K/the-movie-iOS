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
        
        //Populate the elements with the data from ViewController
        titleLabel.text = movieDetail?.title
        if movieDetail?.posterPath != nil {
            titlePoster.load(url: URL(string: "https://image.tmdb.org/t/p/w500" + (movieDetail?.posterPath)!)!)}
        movieOverview.text = movieDetail?.overview
        if let oTitle = movieDetail!.originalTitle{
            originalTitle.text = "Original Title : " + oTitle
        } else {
            originalTitle.text = "TBA"
        }
        if let rating = movieDetail!.voteAverage {
            userRating.text = String(rating) + "/10"
        } else {
            userRating.text = "TBA"
        }
        releaseYear.text = String(movieDetail!.releaseDate ?? "TBA")
        
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
