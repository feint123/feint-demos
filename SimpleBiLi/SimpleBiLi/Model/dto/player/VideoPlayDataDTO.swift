import SwiftUI

struct VideoPlayDataDTO:Decodable {
    let durl:[DurlDTO]
    let format: String
    let timelength: Int
    let quality: Int
}
