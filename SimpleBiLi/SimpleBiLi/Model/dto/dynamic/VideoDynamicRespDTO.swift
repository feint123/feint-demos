import SwiftUI

struct VideoDynamicRespDTO: Decodable {
    let code:Int
    let message:String
    let ttl:Int
    let data:VideoDynamicDataDTO
}
