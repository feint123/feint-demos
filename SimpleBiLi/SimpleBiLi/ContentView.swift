//
//  ContentView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//
import Foundation
import SwiftUI
import AVKit
struct ContentView: View {
    @EnvironmentObject var fetcher: BiliFetcher
    @State var searchVal:String = ""
    @State private var id: Int? = 0
    @State private var avid:Int?
    @State var cvisibility = NavigationSplitViewVisibility.all
    var body: some View {
        VStack {
            NavigationSplitView(columnVisibility: $cvisibility){
                SidebarView(id: $id)
                    .navigationSplitViewColumnWidth(150)
            } content: {
                RegionView(id: $id, avid: $avid)
                    .navigationSplitViewColumnWidth(min: 200, ideal:250, max: 300)
            } detail: {
                if avid != nil {
                    VideoDetailView(avid: $avid)
                } else {
                    VStack(alignment: .center) {
                        Text("")
                        Image("666").resizable()
                            .scaledToFit()
                            .frame(width: 200)
                    }
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
            .navigationTitle("Simple-Bili")
            .searchable(text: $searchVal)
            .onSubmit(of: .search) {
                Task {
                    fetcher.currentKeyword = searchVal
                    id = -1
                    try? await fetcher.getSearchResult(keyword: fetcher.currentKeyword)
                }
            }
            .searchSuggestions {
                ForEach(fetcher.suggests) { suggest in
                    Label(suggest.value, systemImage: "video").searchCompletion(suggest.value)
                }
            }
        }
        .frame(minWidth: 850)
        .onAppear() {
            id = 0
            Task {
                try? await fetcher.getHot()
            }
        }
        .onChange(of: searchVal, perform: { newValue in
            Task {
                // 获取搜索推荐
                try? await fetcher.getSuggest(term: searchVal)
            }
        })
        .onChange(of: id){ id in
            Task {
                // 根据类型更新视频列表
                // 分区列表
                if id == 0 {
                    try? await fetcher.getHot()
                } else if id == 2{
                    try? await fetcher.getRank()
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
                        try? await fetcher.getDynamic(tid: fetcher.currentTid)
                    }
                }
            }
        }
        .onChange(of: avid) { newState in
            Task {
                if let avid = newState {
                    try? await fetcher.getDetail(avid:avid)
                }
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BiliFetcher())
    }
}
