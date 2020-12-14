//
//  RecentSearchCell.swift
//  the-movie-iOS
//
//  Created by Jathinesh Kottem on 10/12/20.
//

import UIKit

class RecentSearchCell: UITableViewCell {
  @IBOutlet weak var recentSearchLabel: UILabel!
  var deleteButtonAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  @IBAction func deleteButtonPressed(_ sender: UIButton) {
    deleteButtonAction?()
  }
  
}
