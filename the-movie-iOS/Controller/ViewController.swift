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
    var pageNo: Int = 1
    var totalPages: Int = 1
    
    
    
    var movieManager = MovieManager()
    var data = [MovieData.Result]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.appName
        //Set delegate for Current ViewController
        collectionView.delegate = self
        collectionView.dataSource = self
        movieManager.delegate = self
        searchTextField.delegate = self
        
        movieManager.fetchData(nil, nil)
        
        //Register CollectionViewCell
        collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
        
    }
    
    //MARK: - Action Sheet
    
    @IBAction func sortButtonPressed(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Sort Order", preferredStyle: .actionSheet)
        
        //Reinitialize data for new API Call
        data = []
        totalPages = 1
        pageNo = 1
        
        let popular = UIAlertAction(title: "Most Popular", style: .default) {_ in
            
            self.movieManager.fetchData("popular", nil)
            
        }
        let topRated = UIAlertAction(title: "Top Rated", style: .default) {_ in
            
            self.movieManager.fetchData("top_rated", nil)
        }
        let nowPlaying = UIAlertAction(title: "Now Playing", style: .default) {_ in
            
            self.movieManager.fetchData("now_playing", nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(nowPlaying)
        optionMenu.addAction(popular)
        optionMenu.addAction(topRated)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        
        
    }
    
}


//MARK: - CollectionView
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MovieCell
        
        //Remove movie poster and title for Clean Transition
        cell.moviePoster.image = nil
        cell.movieTitle.text = nil
        
        cell.movieTitle.text = data[indexPath.row].title
        if data[indexPath.row].posterPath != nil {
            
            cell.moviePoster.load(url: URL(string: Constants.baseImageURL + (data[indexPath.row].posterPath)!)!)
            
        }
        return cell
    }
    
    //Pass the data and Show Movie Details Screen
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        cellIndex = indexPath.row
        performSegue(withIdentifier: Constants.segueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! DetailsViewController
        vc.movieDetail = data[cellIndex]
    }
    //MARK: - Pagination
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if indexPath.row == data.count - 1 {
            updateNextSet()
        }
    }
    
    func updateNextSet() {
        
        if pageNo <= totalPages {
            pageNo += 1
        } else {
            return
        }
        movieManager.performRequest(with: Constants.lastURL, page: pageNo)
//        print(Constants.lastURL + "&page=\(pageNo)")
    }
    
}

//MARK: - CollectionView Layout
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
            self.data.append(contentsOf: api!.results)
            self.totalPages = api!.totalPages
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
            return true
        }
    }
    
    //Implementing search API
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let query = searchTextField.text {
            data = []
            totalPages = 1
            pageNo = 1
            self.movieManager.fetchData(nil, query)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                
            }
        }
        
        searchTextField.text = ""
        
    }
}
