//
//  MovieCell.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 24/11/20.
//

import UIKit

class MovieCell: UICollectionViewCell {
  
  @IBOutlet weak var moviePoster: UIImageView!
  @IBOutlet weak var movieTitle: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    moviePoster.image = nil
  }
}
