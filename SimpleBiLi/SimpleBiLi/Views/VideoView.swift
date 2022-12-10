//
//  VideoView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/7.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @EnvironmentObject var fetcher: BiliFetcher

    @State var player: AVPlayer?
    var body: some View {
        VStack(alignment: .center) {
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(16.0 / 9.0, contentMode: .fill)
            }
        }
        .onChange(of: fetcher.videoDetail.videoLink) { newValue in
            if player?.currentTime() != nil {
                fetcher.playerHistory[fetcher.videoDetail.lastBvid] = player?.currentTime()
            }
            if let url = URL(string: newValue) {
                player?.pause()
                player = AVPlayer(url: url)
                if let time =  fetcher.playerHistory[fetcher.videoDetail.bvid] {
                    player?.seek(to: time, completionHandler: { reutlt in
                        if !reutlt {
                            print("seek failed")
                        }
                    })
                }
                player?.play()
            }
        }
    }
}



struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
    }
}
