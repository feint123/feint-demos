import SwiftUI

struct DurlDTO:Decodable {
    let order:Int
    let url:String
    let backup_url:[String]
}
