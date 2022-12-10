import SwiftUI

struct VideoDynamicDataDTO:Decodable {
    let page:VideoDynamicPageDTO
    let archives:[VideoDynamicArchiveDTO]
}
