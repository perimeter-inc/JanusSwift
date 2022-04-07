//
//  JanusPlayer.swift
//  
//
//  Created by Bruno Wide on 18/03/22.
//

import Foundation
import SwiftUI
import LegacyVideoPlayer

import WebRTC

public struct JanusPlayerView<Loader: View>: UIViewRepresentable {
    
    var videoTrack: RTCVideoTrack?

    var model: JanusPlayerModel?
    var id: String = ""
    var pin: String = ""

    var loadingView: (() -> Loader)?

    var onLoadVideoTrack: ((RTCVideoTrack) -> Void)?

    public func makeUIView(context: Context) -> RTCMTLVideoView {
        let ans = RTCMTLVideoView(frame: .zero)

        if let track = videoTrack {
            track.add(ans)
            return ans
        }
        
        let loaderHost = UIHostingController(rootView: loadingView?())

        ans.addSubview(loaderHost.view)
        loaderHost.view.constraintToEdges(of: ans)
        
        ans.videoContentMode = .scaleAspectFit
        model?.startStreaming(janusId: id, janusPin: pin)

        model?.didLoadVideoTrack = {
            onLoadVideoTrack?($0)
            loaderHost.view.removeFromSuperview()
            $0.add(ans)
        }

        return ans
    }

    public func updateUIView(_ uiView: RTCMTLVideoView, context: Context) {

    }
}

extension UIView {
    func constraintToEdges(of parent: UIView) {

        sizeToFit()
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ])
    }
}
