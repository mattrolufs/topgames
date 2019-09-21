//
//  GetTopGamesUseCase.swift
//  Runner
//
//  Created by Raul Rea on 9/17/19.
//  Copyright © 2019 We Are Envoy. All rights reserved.
//

import Foundation


class GetTopGamesUseCase: AsyncRequestC3<FlutterAsyncUseCase, [String:Any], TopGamesEntity> {
    init(completion: ThrowingHandler<TopGamesEntity>?) {
        super.init(useCase: .TopGamesEntity, parameters: nil, completionHandler: completion)
    }
}
