//
//  ViewController.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 23/11/20.
//

import UIKit
import CoreData
import Kingfisher

class ViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var sortOrderButton: UIButton!
  @IBOutlet weak var SortOrderLabel: UILabel!
  @IBOutlet weak var recentSearchTable: UITableView!
  
  var cellIndex = 0
  var pageNo: Int = 1
  var totalPages: Int = 1
  var movieManager = MovieManager()
  var data = [MovieData.Result]()
  let searchController = UISearchController(searchResultsController: nil)
  let context = CoreDataStack.shared.persistentContainer.viewContext
  var recentSearches = [RecentSearch]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    recentSearchTable.isHidden = true
    //    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    title = Constants.appName
    collectionView.delegate = self
    collectionView.dataSource = self
    recentSearchTable.dataSource = self
    recentSearchTable.delegate = self
    navigationItem.searchController = searchController
    searchController.searchBar.delegate = self
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.hidesSearchBarWhenScrolling = false
    
    let lastSortOrder = UserDefaults.standard.string(forKey: "Last Sort Order")
    apiCaller(lastSortOrder, nil)
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
      UserDefaults.standard.setValue("popular", forKey: "Last Sort Order")
      UserDefaults.standard.setValue("Most Popular", forKey: "Sort Order Label")
      self.reinitializeData()
      self.apiCaller("popular", nil)
    }
    let topRated = UIAlertAction(title: "Top Rated", style: .default) {_ in
      UserDefaults.standard.setValue("top_rated", forKey: "Last Sort Order")
      UserDefaults.standard.setValue("Top Rated", forKey: "Sort Order Label")
      self.reinitializeData()
      self.apiCaller("top_rated", nil)
    }
    let nowPlaying = UIAlertAction(title: "Now Playing", style: .default) {_ in
      UserDefaults.standard.setValue("now_playing", forKey: "Last Sort Order")
      UserDefaults.standard.setValue("Now Playing", forKey: "Sort Order Label")
      self.reinitializeData()
      self.apiCaller("now_playing", nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    
    optionMenu.addAction(nowPlaying)
    optionMenu.addAction(popular)
    optionMenu.addAction(topRated)
    optionMenu.addAction(cancelAction)
    
    self.present(optionMenu, animated: true, completion: nil)
  }
  //MARK: - API Call
  
  func apiCaller(_ category: String?, _ query: String?) {
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.startAnimating()
    movieManager.fetchData(category, query) { (result) in
      DispatchQueue.main.async {
        activityIndicator.stopAnimating()
      }
      self.didUpdate(result)
    }
    SortOrderLabel.text = UserDefaults.standard.string(forKey: "Sort Order Label")
  }
  //MARK: - Update Data
  
  func didUpdate(_ result: (Result<MovieData, someError>)) {
    switch result{
    case .success(let apiData, let statusCode):
      if statusCode == 200 {
        DispatchQueue.main.async {
          let lastIndex = self.data.count
          self.data.append(contentsOf: apiData.results)
          self.totalPages = apiData.totalPages
          if self.pageNo == 1 {
            self.collectionView.reloadData()
          } else {
            let indexPath: [IndexPath] = (0...19).map {IndexPath(row: lastIndex + $0, section: 0)}
            self.collectionView.insertItems(at: indexPath)
          }
        }
      } else if statusCode == 404 {
        print("Page does not exist!")
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
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? MovieCell else {
      fatalError("Expected `\(MovieCell.self)` type for reuseIdentifier \(Constants.cellIdentifier). Check the configuration in Main.storyboard.")
    }
    cell.movieTitle.text = data[indexPath.row].title
    guard let posterPath = data[indexPath.row].posterPath else{return cell}
    cell.moviePoster.tag = indexPath.row
    cell.moviePoster.kf.indicatorType = .activity
    cell.moviePoster.kf.setImage(with: URL(string: Constants.baseImageURL + posterPath))
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    cellIndex = indexPath.row
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    guard let detailsViewController = storyboard.instantiateViewController(identifier: Constants.detailsViewController) as? DetailsViewController else {return}
    detailsViewController.movieDetail = data[cellIndex]
    self.navigationController?.pushViewController(detailsViewController, animated: true)
  }
  //MARK: - Pagination
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == data.count - 1{
      updateNextSet()
    }
  }
  
  func updateNextSet() {
    if pageNo < totalPages {
      pageNo += 1
    } else {
      return
    }
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
    activityIndicator.hidesWhenStopped = true
    activityIndicator.startAnimating()
    self.movieManager.performRequest(with: Constants.lastURL, page: self.pageNo) { result in
      DispatchQueue.main.async {
        activityIndicator.stopAnimating()
      }
      self.didUpdate(result)
    }
  }
}
//MARK: - CollectionView Layout

extension ViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (collectionView.frame.width - 20)/2, height: collectionView.frame.height/2.5)
  }
}
//MARK: - SearchBar

extension ViewController: UISearchBarDelegate {
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    self.collectionView.isHidden = false
    self.recentSearchTable.isHidden = true
    searchBar.endEditing(true)
    searchController.isActive = false
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else {return}
    if query.isEmpty {
      return
    }
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    let newRecentSearch = RecentSearch(context: context)
    newRecentSearch.item = query
    saveItem()
    self.reinitializeData()
    self.apiCaller(nil, query)
    self.SortOrderLabel.text = "Search Results: \(query)"
    searchBar.text = ""
    searchBar.endEditing(true)
    searchController.isActive = false
  }
  
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    recentSearchTable.register(UINib(nibName: Constants.tableCellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
    self.recentSearchTable.isHidden = false
    self.collectionView.isHidden = true
    loadItems()
    recentSearchTable.reloadData()
    return true
  }
  //MARK: - CoreData Functions
  
  func saveItem() {
    do {
      try context.save()
    } catch {
      print("Error saving Item \(error)")
    }
    
    recentSearchTable.reloadData()
  }
  
  func loadItems() {
    let request: NSFetchRequest<RecentSearch> = RecentSearch.fetchRequest()
    do {
      recentSearches = try context.fetch(request)
    } catch {
      print("Error loading Items \(error)")
    }
  }
}
//MARK: - TableView
extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recentSearches.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? RecentSearchCell else {
      fatalError()
    }
    cell.recentSearchLabel.text = recentSearches[indexPath.row].item
    cell.deleteButtonAction = { [unowned self] in
      context.delete(recentSearches[indexPath.row])
      recentSearches.remove(at: indexPath.row)
      saveItem()
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    self.searchController.searchBar.text = recentSearches[indexPath.row].item
  }
  
}
