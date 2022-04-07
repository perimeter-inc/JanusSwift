//
//  File.swift
//  
//
//  Created by Bruno Wide on 23/03/22.
//

import Foundation
import WebRTC
import SwiftUI

public extension JanusPlayerView {

    func onLoadVideoTrack(_ onLoadVideoTrack: @escaping (RTCVideoTrack) -> Void) -> JanusPlayerView {
        JanusPlayerView(videoTrack: videoTrack,
                        model: model,
                        id: id,
                        pin: pin, loadingView: loadingView,
                        onLoadVideoTrack: onLoadVideoTrack)
    }
}
