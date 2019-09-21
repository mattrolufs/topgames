//
//  NativeDataSourceRouter.swift
//  Runner
//
//  Created by Raul Rea on 9/6/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import Foundation

class NativeDataSourceRouter {
    static let shared = NativeDataSourceRouter()
    private init() {}
    
    private var channel: FlutterMethodChannel?
    
    /// Must be set from the landing view controller as the flutter view controller is allocated
    func setup(flutterViewController: FlutterViewController) {
        self.channel = FlutterMethodChannel(name: "dataChannel", binaryMessenger: flutterViewController.binaryMessenger)
        self.channel?.setMethodCallHandler({ [weak self] (call, result) in
            self?.handleFlutterRequests(call, result: result)
        })
    }
    
    private func handleFlutterRequests(_ call: FlutterMethodCall?, result: @escaping FlutterResult) {
        // Get parameters
        let arguments = call?.arguments as? [String: Any]
        let parameters = arguments?["parameters"]
        let method = call?.method.replacingOccurrences(of: "DataChannelRequest.", with: "")
        switch method {
        case "TopGamesEntity":
            NativeTwitchDataSource.shared.requestTopGames { (response) in
                if let response = response {
                    result(["parameters":response])
                } else {
                    result(FlutterError(code: "404", message: "Empty Response", details: nil))
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}
