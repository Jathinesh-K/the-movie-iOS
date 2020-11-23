//
//  ViewController.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var movieManager = MovieManager()
    var data: MovieData? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.delegate = self
//        collectionView.dataSource = self
        movieManager.delegate = self
        
        movieManager.fetchData(nil)
        
    }


}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.results.count ?? 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        
        return cell
    }


}

extension ViewController: MovieDelegate {
    func didUpdate(api: MovieData?) {
        DispatchQueue.main.async {
            self.data = api
            self.collectionView.reloadData()
        }
    }
    
    func didFail(error: Error?) {
        print(error!)
    }
    
    
}
