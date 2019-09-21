//
//  TopGamesEntity.swift
//  Runner
//
//  Created by Raul Rea on 9/17/19.
//  Copyright © 2019 We Are Envoy. All rights reserved.
//

import Foundation

struct TopGamesEntity {
    internal init(data: [GameEntity]?, pagination: [String : String]?) {
        self.data = data
        self.pagination = pagination
    }
    
    var data: [GameEntity]?
    var pagination: [String:String]?
    
    static func mapper(_ map: Dictionary<String,Any>) -> TopGamesEntity? {
        if let data = map["games"] as? [[String:Any]] {
            var gamesArray = [GameEntity]()
            for eachGame in data {
                if let gameEntity = GameEntity.mapper(eachGame) {
                    gamesArray.append(gameEntity)
                }
            }
            return TopGamesEntity(data: gamesArray, pagination: map["pagination"] as? [String:String])
        }
        return nil
    }
}

struct GameEntity {
    internal init(userName: String?, viewerCount: Int?, thumbnailUrl: String?) {
        self.userName = userName
        self.viewerCount = viewerCount
        self.thumbnailUrl = thumbnailUrl
    }
    
//    "id": "35682923360",
//    "user_id": "37402112",
    var userName: String?
//    "game_id": "18122",
//    "type": "live",
//    "title": "I GOT HOJ BIG POGS | @shroud on socials for updates",
    var viewerCount: Int?
//    "started_at": "2019-09-16T22:15:25Z",
//    "language": "en",
    var thumbnailUrl: String?
    
    static func mapper(_ map: Dictionary<String,Any>) -> GameEntity? {
        return GameEntity(userName: map["name"] as? String, viewerCount: map["viewers"] as? Int, thumbnailUrl: map["imageURL"] as? String)
    }
}
