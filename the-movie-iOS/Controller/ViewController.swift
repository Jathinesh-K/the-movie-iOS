//
//  ViewController.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var sortOrderButton: UIButton!
    var movieManager = MovieManager()
    var data: MovieData? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.appName
        collectionView.delegate = self
        collectionView.dataSource = self
        movieManager.delegate = self
        
        movieManager.fetchData(nil)
        
        collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        
    }
    
    @IBAction func sortButtonPressed(_ sender: Any) {
    }
    
}


//MARK: - CollectionView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.results.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MovieCell
        cell.movieTitle.text = data?.results[indexPath.row].title
        cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/w185" + (data?.results[indexPath.row].posterPath)!)!)
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 180, height: 280)
        return size
    }
}


//MARK: - Movie Delegate
extension ViewController: MovieDelegate {
    func didUpdate(api: MovieData?) {
        DispatchQueue.main.async {
            self.data = api
            print(self.data?.results.count)
            self.collectionView.reloadData()
        }
    }
    
    func didFail(error: Error?) {
        print(error!)
    }
    
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
