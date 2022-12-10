import SwiftUI

struct VideoDetailRespDTO:Decodable {
    let code:Int
    let message:String
    let ttl:Int
    let data:VideoDetailDataDTO
}
