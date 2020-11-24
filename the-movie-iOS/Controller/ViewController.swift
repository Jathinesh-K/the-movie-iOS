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
    @IBOutlet weak var searchTextField: UITextField!
    var cellIndex = 0
    
    
    
    var movieManager = MovieManager()
    var data: MovieData? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.appName
        collectionView.delegate = self
        collectionView.dataSource = self
        movieManager.delegate = self
        searchTextField.delegate = self
        
        movieManager.fetchData(nil, nil)
        
        collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        
    }
    
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Sort Order", preferredStyle: .actionSheet)
        
        let popular = UIAlertAction(title: "Most Popular", style: .default) {_ in
            
            self.movieManager.fetchData("popular", nil)
            
        }
        let topRated = UIAlertAction(title: "Top Rated", style: .default) {_ in
            
            self.movieManager.fetchData("top_rated", nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(popular)
        optionMenu.addAction(topRated)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
}


//MARK: - CollectionView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.results.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MovieCell
                cell.moviePoster.image = nil
                cell.movieTitle.text = nil
        
        cell.movieTitle.text = data?.results[indexPath.row].title
        if data?.results[indexPath.row].posterPath != nil {
            cell.moviePoster.load(url: URL(string: "https://image.tmdb.org/t/p/w500" + (data?.results[indexPath.row].posterPath)!)!)}
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellIndex = indexPath.row
        performSegue(withIdentifier: Constants.segueIdentifier, sender: self)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! DetailsViewController
        vc.movieDetail = data?.results[cellIndex]
        
    }
    
    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 180, height: 265)
        return size
    }
}


//MARK: - Movie Delegate
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

//MARK: - ImageView from API
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

//MARK: - SearchTextField

extension ViewController: UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            //            textField.placeholder = "Type something"
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let query = searchTextField.text {
            self.movieManager.fetchData(nil, query)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }
        
        searchTextField.text = ""
        
    }
}


//Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
//    self.collectionView.reloadData()
//}
