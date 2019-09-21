//
//  NativeTwitchDataSource.swift
//  Runner
//
//  Created by Raul Rea on 9/9/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation
import Alamofire

class NativeTwitchDataSource {
    static let shared = NativeTwitchDataSource()
    private init() { }
    
    func requestTopGames(completion: @escaping ([String:Any]?) -> Void) {
        request("https://api.twitch.tv/helix/streams?limit=20", method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["Client-ID":"cblvo3evoxpn8duahtlvdw388dxezr"]).response { (response) in
            if let data = response.data, let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any], let gamesMap = json["data"] as? [[String:Any]] {
                var parsedGames = [[String: Any]]()
                for eachGame in gamesMap {
                    let map = ["name": eachGame["user_name"] ?? "Name not found", "viewers": eachGame["viewer_count"] ?? 0, "imageURL":eachGame["thumbnail_url"] ?? ""]
                    parsedGames.append(map)
                }

                let parsedGamesMap = ["games":parsedGames]
                completion(parsedGamesMap)
                return
            }
            completion(nil)
        }
    }
}
