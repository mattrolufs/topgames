//
//  TwitchStreamCollectionViewCell.swift
//  Runner
//
//  Created by Adam Ake on 9/18/19.
//  Copyright © 2019 We Are Envoy. All rights reserved.
//

import UIKit

class TwitchStreamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewersLabel: UILabel!
    
    func update(with game: GameViewModel) {
        DispatchQueue.main.async {
            self.titleLabel.text = game.name
            self.viewersLabel.text = "\(game.viewers ?? "\(1)") watching"
            
            if let imageUrl = game.imageUrl {
                let widthModImageURL = imageUrl.replacingOccurrences(of: "{width}", with: "600")
                let modifiedImageURL = widthModImageURL.replacingOccurrences(of: "{height}", with: "360")
                if let url = URL(string: modifiedImageURL) {
                    URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }

                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.imageView.image = UIImage(data: imageData)
                                let transition = CATransition()
                                transition.type = .fade
                                transition.duration = 0.2
                                self.imageView.layer.add(transition, forKey: "loadImage")
                            }
                        }
                    }).resume()
                }
            }
        }
    }
}
