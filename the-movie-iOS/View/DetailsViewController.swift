//
//  DetailsViewController.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 24/11/20.
//

import UIKit

class DetailsViewController: UIViewController {

    var movieDetail: MovieData.Result?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titlePoster: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movieDetail?.title
        if movieDetail?.posterPath != nil {
            titlePoster.load(url: URL(string: "https://image.tmdb.org/t/p/w500" + (movieDetail?.posterPath)!)!)}
        
              // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - ImageView

//extension UIImageView {
//    func load(url: URL) {
//        DispatchQueue.global().async { [weak self] in
//            if let data = try? Data(contentsOf: url) {
//                if let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        self?.image = image
//                    }
//                }
//            }
//        }
//    }
//}
