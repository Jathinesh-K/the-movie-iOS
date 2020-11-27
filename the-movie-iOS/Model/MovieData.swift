//
//  MovieData.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import Foundation


struct MovieData: Codable {
  var results: [Result]
  let page, totalResults: Int
  let totalPages: Int
  
  // MARK: - Result
  struct Result: Codable {
    let popularity: Double?
    let voteCount: Int?
    let posterPath: String?
    let originalTitle: String?
    let title: String?
    let voteAverage: Double?
    let overview, releaseDate: String?
  }
}
