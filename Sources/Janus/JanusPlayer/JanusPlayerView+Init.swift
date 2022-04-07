//
//  File.swift
//  
//
//  Created by Bruno Wide on 24/03/22.
//

import Foundation
import SwiftUI
import WebRTC

extension JanusPlayerView {

    public init(videoTrack: RTCVideoTrack) {
        self.videoTrack = videoTrack
    }

    public init(videoTrack: RTCVideoTrack, loader: @escaping () -> Loader) {
        self.videoTrack = videoTrack
        self.loadingView = loader
    }

    public init(api: JanusAPI, id: String, pin: String) {
        self.model = JanusPlayerModel(api: api)
        self.id = id
        self.pin = pin
    }

    public init(api: JanusAPI, id: String, pin: String, loader: @escaping () -> Loader) {
        self.model = JanusPlayerModel(api: api)
        self.id = id
        self.pin = pin
        self.loadingView = loader
    }
}
