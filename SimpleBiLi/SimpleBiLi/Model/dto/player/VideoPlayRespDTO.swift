import SwiftUI

struct VideoPlayRespDTO:Decodable {
    let code:Int
    let message:String
    let data:VideoPlayDataDTO;
}
