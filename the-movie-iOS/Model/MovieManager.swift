//
//  MovieManager.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import Foundation

protocol MovieDelegate {
  func didUpdate(api: MovieData)
  func didFail(error: Error?)
}

struct MovieManager {
  let baseURL = "https://api.themoviedb.org/3/"
  var delegate: MovieDelegate?
  
  func fetchData(_ category: String?, _ query: String?) {
    if let safeQuery = query{
      let finalURL = baseURL + "search/movie" + Constants.apiKey + "&query=" + safeQuery
      
      //Set the last used URL for pagination
      if Constants.lastURL != finalURL {
        Constants.lastURL = finalURL
      }
      
      return performRequest(with: finalURL, page: 1)
    } else {
      let text = category ?? "now_playing"
      let finalURL = baseURL + "movie/" + text + Constants.apiKey
      
      if Constants.lastURL != finalURL {
        Constants.lastURL = finalURL
      }
      
      return performRequest(with : finalURL, page: 1)
    }
  }
  
  func performRequest(with urlString: String, page: Int) {
    if let url = URL(string: urlString + "&page=\(page)") {
      
      let session = URLSession(configuration: .default)
      
      let task = session.dataTask(with: url) { (data, response, error) in
        if error != nil {
          print(error!)
          self.delegate?.didFail(error: error)
          
          return
        }
        
        if let safeData = data {
          
          if let decodedData = self.parseJSON(safeData) {
            self.delegate?.didUpdate(api: decodedData)
          }
        }
      }
      task.resume()
    }
  }
  
  func parseJSON(_ apiData: Data) -> MovieData?{
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    do {
      let decodedData = try decoder.decode(MovieData.self, from: apiData)
      
      return decodedData
    } catch {
      self.delegate?.didFail(error: error)
      
      return  nil
    }
    
    
  }
}
