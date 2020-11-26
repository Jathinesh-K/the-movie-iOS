//
//  MovieManager.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import Foundation

struct MovieManager {
  
  func fetchData(_ category: String?, _ query: String?, _ completionHandler: @escaping (MovieData) -> Void) {
    guard let safeQuery = query else{
      
      let text = category ?? "now_playing"
      let finalURL = Constants.baseURL + "movie/" + text + Constants.apiKey
      //Set the last used URL for pagination
      if Constants.lastURL != finalURL {
        Constants.lastURL = finalURL
      }
      return performRequest(with : finalURL, page: 1, completionHandler)
    }
    
    let finalURL = Constants.baseURL + "search/movie" + Constants.apiKey + "&query=" + safeQuery
    if Constants.lastURL != finalURL {
      Constants.lastURL = finalURL
    }
    return performRequest(with: finalURL, page: 1, completionHandler)
  }
  
  func performRequest(with urlString: String, page: Int, _ completionHandler: @escaping (MovieData) -> Void) {
    if let url = URL(string: urlString + "&page=\(page)") {
      
      let session = URLSession(configuration: .default)
      
      let task = session.dataTask(with: url) { (data, response, error) in
        
        if error != nil {
          print(error!.localizedDescription)
          return
        }
        
        if let safeData = data {
          
          if let decodedData = self.parseJSON(safeData) {
            
            completionHandler(decodedData)
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
      
      print(error.localizedDescription)
      return  nil
    }
  }
}
