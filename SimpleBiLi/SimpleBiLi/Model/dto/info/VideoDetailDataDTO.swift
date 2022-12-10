import SwiftUI

struct VideoDetailDataDTO:Decodable {
    let bvid:String
    let aid:Int
    let tid:Int
    let cid:Int
    let tname:String
    let pic:String
    let title:String
    let desc:String
    let owner:OwnerDTO
}
