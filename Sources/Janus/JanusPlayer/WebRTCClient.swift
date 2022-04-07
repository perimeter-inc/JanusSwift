//
//  WebRTCClient.swift
//  
//
//  Created by Bruno Wide on 20/03/22.
//

import Foundation
import WebRTC

protocol WebRTCClientProtocol {
    var delegate: WebRTCClientDelegate? { get set }

    func answer(remoteSdp: String, completion: @escaping (String) -> Void)
}

final class WebRTCClient: NSObject, WebRTCClientProtocol {
    static let shared = WebRTCClient()

    private let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()

    private let configuration: RTCConfiguration = {
        let iceServers = ["stun:stun.l.google.com:19302",
                          "stun:stun1.l.google.com:19302",
                          "stun:stun2.l.google.com:19302",
                          "stun:stun3.l.google.com:19302",
                          "stun:stun4.l.google.com:19302"]
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        return config
    }()

    private let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
    private var remoteVideoTrack: RTCVideoTrack?
    private var peerConnection: RTCPeerConnection?

    weak var delegate: WebRTCClientDelegate?

    func answer(remoteSdp: String, completion: @escaping (String) -> Void) {
        peerConnection = factory.peerConnection(with: configuration, constraints: constraints, delegate: nil)
        peerConnection?.delegate = self
        peerConnection?.setRemoteDescription(.init(type: .offer, sdp: remoteSdp)) { [unowned self] error in
            guard error == nil else { return }
            let constrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
            self.peerConnection?.answer(for: constrains) { [unowned self] sessionDescription, _ in
                guard let sessionDescription = sessionDescription else { return }
                self.peerConnection?.setLocalDescription(sessionDescription) { error in
                    guard error == nil else { return }
                    completion(sessionDescription.sdp)
                }
            }
        }
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didStartReceivingOn transceiver: RTCRtpTransceiver) {
        if case .video = transceiver.mediaType {
            remoteVideoTrack = transceiver.receiver.track as? RTCVideoTrack
            delegate?.webRTCClient(self, didSetRemoteVideoTrack: remoteVideoTrack!)
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }

    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClientProtocol, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClientProtocol, didSetRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
}
