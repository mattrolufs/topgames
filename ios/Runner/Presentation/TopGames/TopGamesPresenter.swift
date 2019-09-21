//
//  TopGamesPresenter.swift
//  Runner
//
//  Created by Raul Rea on 9/17/19.
//  Copyright © 2019 We Are Envoy. All rights reserved.
//

import Foundation

enum TopGamesInterface: PresentableC3 {
    typealias ViewModel = TopGamesViewModel
    typealias Presenter = TopGamesPresenter
}

struct GameViewModel {
    init(name: String? = "No name", viewers: String? = "--", imageUrl: String? = nil) {
        self.name = name
        self.viewers = viewers
        self.imageUrl = imageUrl
    }
    
    var name: String?
    var viewers: String?
    var imageUrl: String?
}

struct TopGamesViewModel {
    var games = [GameViewModel]()
}

class TopGamesPresenter: PresenterC3 {
    var viewModel: TopGamesViewModel? = TopGamesViewModel()
    var error: DomainError?
    var displayLogic: (DisplayableStateC3) -> Void
    
    required init(displayLogic: @escaping (DisplayableStateC3) -> Void) {
        self.displayLogic = displayLogic
    }
    
    typealias Interface = TopGamesInterface
    
    private let repo = FlutterRepo.shared
    func getTopGames() {
        let useCase = GetTopGamesUseCase() { (throwingResponse) in
            if let response = try? throwingResponse() {
                if let games = response.data {
                    for eachGame in games {
                        let viewers = "\(eachGame.viewerCount ?? 0)"
                        let eachGameViewModel = GameViewModel(name: eachGame.userName, viewers: viewers, imageUrl: eachGame.thumbnailUrl)
                        self.viewModel?.games.append(eachGameViewModel)
                    }
                    self.displayLogic(.populated)
                } else {
                    self.error = DomainError.parsingError
                    self.displayLogic(.error)
                }
            } else {
                 self.error = DomainError.sourceError
                self.displayLogic(.error)
            }
        }
        repo.performAsyncRequest(useCase, mapper: TopGamesEntity.mapper)
    }
    
}
