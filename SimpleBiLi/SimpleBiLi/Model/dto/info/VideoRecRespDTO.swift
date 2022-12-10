import SwiftUI

struct VideoRecRespDTO:Decodable {
    let code:Int
    let message:String
    let data:[VideoDetailDataDTO]
}
