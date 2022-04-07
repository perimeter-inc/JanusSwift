//
//  File.swift
//  
//
//  Created by Bruno Wide on 18/03/22.
//

import Foundation
import WebRTC

public class JanusPlayerModel: ObservableObject {

    var sessionId: Int? {
        didSet {
            startKeepAliveTimer()
        }
    }

    var handleId: Int?
    var streamId: Int?
    var started = false

    private var keepAliveTimer: DispatchSourceTimer?
    private let session: JanusAPI
    private let webRTCClient = WebRTCClient()

    var didLoadVideoTrack: ((RTCVideoTrack) -> Void)?

    public init(api: JanusAPI) {
        session = api
        webRTCClient.delegate = self
    }

    public func startStreaming(janusId: String, janusPin: String) {
        session.createSession { [weak self] sessionId in
            guard let self = self else { return }
            self.sessionId = sessionId
            self.session.attachPlugin(sessionId: sessionId, plugin: .streaming) { [weak self] handleId in
                self?.handleId = handleId
                self?.session.watch(sessionId: sessionId, handleId: handleId, streamId: janusId, pin: janusPin) { [weak self] remoteSdp in
                    self?.webRTCClient.answer(remoteSdp: remoteSdp) { [weak self] localSdp in
                        self?.session.start(sessionId: sessionId, handleId: handleId, sdp: localSdp) { [weak self] in
                            self?.started = true
                        }
                    }
                }
            }
        }
    }

    private func startKeepAliveTimer() {
        keepAliveTimer = DispatchSource.makeTimerSource()
        keepAliveTimer?.schedule(deadline: .now() + .seconds(50), repeating: .seconds(50))
        keepAliveTimer?.setEventHandler { [unowned self] in
            guard let sessionId = self.sessionId else { return }
            self.session.keepAlive(sessionId: sessionId)
        }
        keepAliveTimer?.resume()
    }

    func stopKeepAliveTimer() {
        keepAliveTimer?.cancel()
    }
}

extension JanusPlayerModel: WebRTCClientDelegate {
    func webRTCClient(_: WebRTCClientProtocol, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        guard let sessionId = sessionId, let handleId = handleId else { return }

        session.trickle(sessionId: sessionId,
                        handleId: handleId,
                        candidate: candidate.sdp,
                        sdpMLineIndex: candidate.sdpMLineIndex,
                        sdpMid: candidate.sdpMid)
    }

    func webRTCClient(_: WebRTCClientProtocol, didSetRemoteVideoTrack remoteVideoTrack: RTCVideoTrack) {
        DispatchQueue.main.async {
            self.didLoadVideoTrack?(remoteVideoTrack)
        }
    }
}
