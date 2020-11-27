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
    //    movieManager.delegate = self
    searchTextField.delegate = self
    
    movieManager.fetchData(nil, nil) { result in
      self.didUpdate(result)
    }
    
    //Register CollectionViewCell
    collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellIdentifier)
    
  }
  
  func reinitializeData() {
    data = []
    totalPages = 1
    pageNo = 1
  }
  
  //MARK: - Action Sheet
  
  @IBAction func sortButtonPressed(_ sender: UIButton) {
    let optionMenu = UIAlertController(title: nil, message: "Choose Sort Order", preferredStyle: .actionSheet)
    
    let popular = UIAlertAction(title: "Most Popular", style: .default) {_ in
      self.reinitializeData()
      self.movieManager.fetchData("popular", nil){ result in
        self.didUpdate(result)
      }
      
    }
    
    let topRated = UIAlertAction(title: "Top Rated", style: .default) {_ in
      self.reinitializeData()
      self.movieManager.fetchData("top_rated", nil){ result in
        self.didUpdate(result)
      }
    }
    
    let nowPlaying = UIAlertAction(title: "Now Playing", style: .default) {_ in
      self.reinitializeData()
      self.movieManager.fetchData("now_playing", nil){ result in
        self.didUpdate(result)
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    optionMenu.addAction(nowPlaying)
    optionMenu.addAction(popular)
    optionMenu.addAction(topRated)
    optionMenu.addAction(cancelAction)
    
    self.present(optionMenu, animated: true, completion: nil)
  }
  
  //MARK: - Update Data
  
  func didUpdate(_ result: (Result<MovieData, someError>)) {
    switch result{
    case .success(let apiData, let statusCode):
      if statusCode == 200 {
        DispatchQueue.main.async {
          self.data.append(contentsOf: apiData.results)
          self.totalPages = apiData.totalPages
          self.collectionView.reloadData()
        }
      }
    case .failure(let error, _):
      print(error.localizedDescription)
    }
  }
}
//MARK: - CollectionView

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! MovieCell
    
    cell.movieTitle.text = data[indexPath.row].title
    guard let posterPath = data[indexPath.row].posterPath else{return cell}
    
    cell.moviePoster.load(url: URL(string: Constants.baseImageURL + posterPath)!)
    
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
    movieManager.performRequest(with: Constants.lastURL, page: pageNo){ result in
      self.didUpdate(result)
    }
  }
}

//MARK: - CollectionView Layout

extension ViewController: UICollectionViewDelegateFlowLayout{
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: 180, height: 265)
    return size
  }
}

//MARK: - ImageView from API

//let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
  func load(url: URL) {
    DispatchQueue.global().async { [weak self] in
      //ImageCache Implementation
      //      self!.image = nil
      //      if let imageFromCache = imageCache.object(forKey: url as AnyObject) as? UIImage{
      //        self?.image = imageFromCache
      //        return
      //      }
      if let data = try? Data(contentsOf: url) {
        
        if let image = UIImage(data: data) {
          DispatchQueue.main.async {
            //            let imageToCache = image
            //            imageCache.setObject(imageToCache, forKey: url as AnyObject)
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
      self.reinitializeData()
      self.movieManager.fetchData(nil, query){ result in
        self.didUpdate(result)
      }
      
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
    
    searchTextField.text = ""
  }
}
