import Foundation

struct WatchResponse: Decodable {
    var janus = "ack"
    let sessionId: Int
    let transaction: String
}
