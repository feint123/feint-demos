//
//  ViedoDetailView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import Foundation

import SwiftUI
import AVKit

struct VideoDetailView: View {
    @EnvironmentObject var fetcher: BiliFetcher
    @Binding var avid:Int?
    @State var hoverPlayBtn = false
    let columns = [GridItem(.adaptive(minimum: 225))]
    @Environment(\.openWindow) private var openVideo
    var body: some View {
        List(selection: $avid) {
            
            VideoView()
            
            Section("视频信息") {
                VideoInfoView()
            }
            
            if fetcher.recVideoList.count > 0 {
                Section("相关推荐") {
                    LazyVGrid(columns: columns, alignment: .leading) {
                        ForEach($fetcher.recVideoList, id: \.avid) { $videoItem in
                            Button {
                                avid = videoItem.avid
                            } label: {
                                VideoCardView(videoItem: $videoItem)
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .onChange(of: avid) { newValue in
            Task {
                if let avid = newValue {
                    try? await fetcher.getDetail(avid:avid)
                }
            }
        }
    }
    
}

struct VideoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VideoDetailView(avid: Binding.constant(1)).environmentObject(BiliFetcher())
    }
}
