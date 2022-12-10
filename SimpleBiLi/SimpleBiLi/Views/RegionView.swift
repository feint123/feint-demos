//
//  RegionView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//


import SwiftUI

struct RegionView: View {
    @EnvironmentObject var fetcher: BiliFetcher
    @Binding var id:Int
    @Binding var avid:Int?
    
    var body: some View {
 
        List($fetcher.videoList, id: \.avid, selection: $avid){ $videoItem in
            VideoCardView(videoItem: $videoItem)
                .onAppear(perform: {
                    if fetcher.videoList.isLastItem(videoItem) {
                        Task {
                            if id == 0 {
                                try? await fetcher.getHot(page: fetcher.regionPage + 1, newSearch: false)
                            } else if id == -1 {
                                try? await fetcher.getSearchResult(keyword: fetcher.currentKeyword, page: fetcher.regionPage + 1, newSearch: false)
                            } else {
                                var type = -1
                                fetcher.sidebars.forEach { section in
                                    section.items.forEach { item in
                                        if item.id == id {
                                            fetcher.currentTid = item.tid
                                            type = section.type
                                        }
                                    }
                                }
                                if type == 1 {
                                    try? await fetcher.getDynamic(tid: fetcher.currentTid, page: fetcher.regionPage + 1, newSearch: false)
                                }
                            }
                        }
                    }
                })
            //
        }.listStyle(.automatic)
    }
}

struct RegionView_Previews: PreviewProvider {
    static var previews: some View {
        RegionView(id: .constant(0), avid: .constant(0)).environmentObject(BiliFetcher())
    }
}
