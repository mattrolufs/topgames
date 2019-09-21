//
//  TopGamesViewController.swift
//  Runner
//
//  Created by Raul Rea on 9/17/19.
//  Copyright © 2019 We Are Envoy. All rights reserved.
//

import UIKit

class TopGamesViewController: UIViewController, DisplayableC3 {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    private var viewsWereLaidOut = false
    @IBOutlet weak var titleLabel: UILabel!
    
    func display(_ state: DisplayableStateC3) {
        switch state {
            
        case .empty:
            break
        case .error:
             print("Got error: \(String(describing: presenter?.error))")
        case .populated:
            print("Got data: \(String(describing: presenter?.viewModel))")
            self.collectionView.dataSource = self
            self.collectionView.delegate = self
            
        case .loading:
            print("Loading data")
        }
    }
    
    var presenter: TopGamesPresenter?
    
    typealias Interface = TopGamesInterface
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.display(.loading)
        self.registerCells()
        self.presenter?.getTopGames()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewsWereLaidOut {
            viewsWereLaidOut = true
            
            self.collectionView.contentInset = UIEdgeInsets(top: self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 16,
                                                            left: Constants.edgeMargins,
                                                            bottom: 0,
                                                            right: Constants.edgeMargins)
        }
    }
    
    private func registerCells() {
        self.collectionView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.cellNibName)
    }
    
    enum Constants {
        static let numberOfColumns: CGFloat = 2
        static let cellImageAspect: CGFloat = 16.0/9.0
        static let cellAdditionalHeight: CGFloat = 30.0
        static let edgeMargins: CGFloat = 16.0
        static let betweenSpace: CGFloat = 8.0
        static let cellNibName = "TwitchStreamCollectionViewCell"
    }
}

extension TopGamesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let cellWidth = ((screenWidth / Constants.numberOfColumns) - Constants.betweenSpace) - Constants.edgeMargins
        return CGSize(width: cellWidth, height: (cellWidth / Constants.cellImageAspect) + Constants.cellAdditionalHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter?.viewModel?.games.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TwitchStreamCollectionViewCell", for: indexPath)
        if let game = self.presenter?.viewModel?.games[indexPath.item], let cell = collectionViewCell as? TwitchStreamCollectionViewCell {
            cell.update(with: game)
        }
        
        return collectionViewCell
    }
}

extension TopGamesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y > -60 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: {
                    self.titleLabel.alpha = 0
                }, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState], animations: {
                    self.titleLabel.alpha = 1
                }, completion: nil)
            }
        }
    }
}
