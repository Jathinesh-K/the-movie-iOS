//
//  MovieManager.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import Foundation

protocol MovieDelegate {
    func didUpdate(api: MovieData?)
    func didFail(error: Error?)
}

struct MovieManager {
    let baseURL = "https://api.themoviedb.org/3/"
    var delegate: MovieDelegate?
    
    func fetchData(_ category: String?, _ query: String?) {
        if let safeQuery = query{
            let finalURL = baseURL + "search/movie" + "?api_key=1f905a852b95d49aad26cde642046599&query=" + safeQuery
            
            return performRequest(with: finalURL)
        } else {
            let text = category ?? "now_playing"
            let finalURL = baseURL + "movie/" + text + "?api_key=1f905a852b95d49aad26cde642046599"
            
            return performRequest(with : finalURL)
        }
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            
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
        do {
            let decodedData = try decoder.decode(MovieData.self, from: apiData)
            
            return decodedData
        } catch {
            self.delegate?.didFail(error: error)
            
            return  nil
        }
        
        
    }
}
