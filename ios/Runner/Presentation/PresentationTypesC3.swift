//
//  PresentationTypes.swift
//  MasterBuilt
//
//  Created by Raul Rea on 4/21/19.
//  Copyright © 2019 Raul Rea Menacho. All rights reserved.
//

import Foundation

// MARK: - Presentation Types
typealias Nothing = () -> Void

enum DisplayableStateC3 {
    case empty
    case error
    case populated
    case loading
}

// MARK: - Presetnation Protocols
protocol PresentableC3 {
    associatedtype ViewModel
    associatedtype Presenter: PresenterC3 where Presenter.Interface == Self
}

protocol PresenterC3: class {
    associatedtype Interface: PresentableC3
    typealias DisplayLogic = (_ state: DisplayableStateC3) -> Void
    var viewModel: Interface.ViewModel? { get set }
    var error: DomainError? { get set }
    var displayLogic: DisplayLogic { get set }
    init(displayLogic: @escaping DisplayLogic)
}

protocol DisplayableC3: class  {
    associatedtype Interface: PresentableC3
    func display(_ state: DisplayableStateC3)
    var presenter: Interface.Presenter? {get set}
}

extension DisplayableC3 {
    func setup() {
        self.presenter = Interface.Presenter.init{ [weak self] state in
            return self?.display(state)
        }
    }
}

extension PresenterC3 {
    func removeObservers() {
        // Must be overriden to remove observers from its Repo, if the presenter is using observers.
    }
}


// Example usage

struct ThatViewModel {
    let oneConstant = "yep"
}

enum ThatPresentable: PresentableC3 {
    typealias Presenter = ThatPresenter
    typealias ViewModel = ThatViewModel
}


class ThatPresenter: PresenterC3 {
    required init(displayLogic: @escaping DisplayLogic) {
        self.displayLogic = displayLogic
    }
    
    var viewModel: ThatViewModel?
    var error: DomainError?
    var displayLogic: DisplayLogic
    typealias Interface = ThatPresentable
    func goGetSomething() {
        print("go get somethign called")
        self.viewModel = ThatViewModel()
        self.displayLogic(.populated)
    }
    
    deinit {
        print("that presenter killed")
    }
}

class ThatDisplayLogic: UIView, DisplayableC3 {
    
    typealias Interface = ThatPresentable
    var presenter: ThatPresenter?
    
    func display(_ state: DisplayableStateC3) {
        print("🔥displaying state \(state)")
    }
    
    func loadYou() {
        print("load you called")
        self.presenter?.goGetSomething()
    }
    
    deinit {
        print("that display logic killed")
    }
}
