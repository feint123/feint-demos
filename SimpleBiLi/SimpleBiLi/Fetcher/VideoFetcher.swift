//
//  VideoFetcher.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import Foundation

import SwiftUI

extension BiliFetcher {
    /**
     获取分区视频
     */
    func getDynamic(tid: Int, page: Int = 1, newSearch: Bool = true) async throws{
     
        guard let url = URL(string: VIDEO_DYNAMIC_URL+"pn=\(page)&ps=10&rid=\(tid)") else {
            return
        }
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let decoder = JSONDecoder()
        let resultMap:VideoDynamicRespDTO = try decoder.decode(VideoDynamicRespDTO.self, from: data)
        var tempList:[VideoItem] = []
        resultMap.data.archives.forEach { dto in
            let item = VideoItem(title: dto.title, mainImage: UrlUtils.toSafeUrl(url: dto.pic), author: dto.owner.name,
                                 face: UrlUtils.toSafeUrl(url: dto.owner.face), avid: dto.aid,  bvid: dto.bvid)
            tempList.append(item)
        }
        let _tempList = tempList;
        
        DispatchQueue.main.async {
            if newSearch {
                self.videoList.removeAll()
            }
            self.videoList.append(contentsOf: _tempList)
            self.regionPage = page
        }
    }
    /**
    获取热门视频
     */
    func getHot(page: Int = 1, newSearch: Bool = true) async throws{
     
        guard let url = URL(string: VIDEO_HOT_URL+"pn=\(page)&ps=10") else {
            return
        }
       
        try await getNormalVideoList(url: url, page: page, newSearch: newSearch)
    
    }
    
    /**
    获取视频排行榜
     */
    func getRank(newSearch: Bool = true) async throws{
     
        guard let url = URL(string: VIDEO_RANK_URL) else {
            return
        }
        
        try await getNormalVideoList(url: url, page: 1, newSearch: newSearch)
        
    }
    
    /**
     设置一些通用的视频列表参数
     */
    func getNormalVideoList(url: URL, page: Int, newSearch:Bool) async throws {
        do {
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            let json = try JSON(data: data)
            if json["code"].int != 0 {
                return
            }
            let _data = json["data"]
            let resultMap = _data["list"].array
            var tempList:[VideoItem] = []
            resultMap?.forEach { video in
                let item = VideoItem(title: video["title"].string!, mainImage:  UrlUtils.toSafeUrl(url: video["pic"].string!),
                                     author: video["owner"]["name"].string!, face: UrlUtils.toSafeUrl(url: video["owner"]["face"].string!) ,
                                     avid: video["aid"].int!, bvid: video["bvid"].string!)
                tempList.append(item)
            }
            let _tempList =  tempList
            DispatchQueue.main.async {
                if newSearch {
                    self.videoList.removeAll()
                }
                self.videoList.append(contentsOf: _tempList)
                self.regionPage = page
            }
            
        } catch {
            print("\(error)")
        }
    }
    
   
    /**
     获取视频详情
     */
    func getDetail(avid: Int) async throws{
        guard let url = URL(string:VIDEO_DETAIL_URL+"\(avid)") else {
            return
        }
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let decoder = JSONDecoder()
        let resultMap:VideoDetailRespDTO = try  decoder.decode(VideoDetailRespDTO.self, from:data)
//        print(resultMap.data.bvid)
        DispatchQueue.main.async {
            self.videoDetail.videoImg = UrlUtils.toSafeUrl(url: resultMap.data.pic)
            self.videoDetail.title=resultMap.data.title
            self.videoDetail.introduce=resultMap.data.desc
            self.videoDetail.upInfo.name=resultMap.data.owner.name
            self.videoDetail.upInfo.headImage=UrlUtils.toSafeUrl(url: resultMap.data.owner.face)
            self.videoDetail.lastBvid = self.videoDetail.bvid
            self.videoDetail.bvid = resultMap.data.bvid
        }
        // 拼接视频流地址
//        guard let videoStreamUrl = URL(string: self.VIDEO_PLAY_URL+"cid=\(resultMap.data.cid)&bvid=\(resultMap.data.bvid)") else {return}
//        // 请求视频流地址
//        let (playData, _) = try await URLSession.shared.data(for: URLRequest(url: videoStreamUrl))
////        print(String(bytes: playData, encoding: .utf8))
//        let viewPlayMap:VideoPlayRespDTO = try decoder.decode(VideoPlayRespDTO.self, from: playData)
//        self.videoDetail.videoLink = viewPlayMap.data.durl[0].backup_url[0]
        
        let link: String
        // 从cache中取数据，减少请求
        if let videoLink = self.playerUrlMap[resultMap.data.bvid] {
            link = videoLink
        } else {
            guard let videoStreamUrl = URL(string: self.THIRD_PLAY_URL+"\(resultMap.data.aid)") else {return}
            //         请求视频流地址
            let (playData, _) = try await URLSession.shared.data(for: URLRequest(url: videoStreamUrl))
            link = String(bytes: playData, encoding: .utf8) ?? ""
        }

        DispatchQueue.main.async {
            self.videoDetail.videoLink = UrlUtils.toSafeUrl(url: link)
        }

        // 拼接相关推荐视频地址
        guard let recUrl = URL(string: self.VIDEO_REC_URL+"\(avid)") else {return}
        let (recData, _) = try await URLSession.shared.data(for: URLRequest(url: recUrl))
        let recMap: VideoRecRespDTO = try decoder.decode(VideoRecRespDTO.self, from: recData)
        DispatchQueue.main.async {
            self.recVideoList.removeAll()
        }			
        recMap.data.forEach { dto in
            let item = VideoItem(title: dto.title, mainImage: UrlUtils.toSafeUrl(url: dto.pic),
                                 author: dto.owner.name, face: UrlUtils.toSafeUrl(url: dto.owner.face),  avid: dto.aid, bvid: dto.bvid)
            DispatchQueue.main.async {
                self.recVideoList.append(item)
            }
        }
    }
}

/**
 * 搜索相关
 */
extension BiliFetcher {
    /**
     * 获取搜索建议
     */
    func getSuggest(term: String) async throws{
        let originUrl = self.SEARCH_SUGGEST_URL+"\(term)"
        let safeUrl = originUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = safeUrl, let url = URL(string:url) else {
            return
        }
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        
        let decoder = JSONDecoder()
        do {
            let resultMap:Dictionary = try decoder.decode(Dictionary<String, SearchSuggestRespDTO>.self, from:data)
            DispatchQueue.main.async {
                self.suggests.removeAll()
            }
            resultMap.forEach { (key: String, value: SearchSuggestRespDTO) in
                DispatchQueue.main.async {
                    // 只取Top10的搜索建议
                    if self.suggests.count <= 10 {
                        self.suggests.append(SearchSuggest(term: value.term, value: value.value))
                    }
                }
            }
        }catch {
            print("\(error)")
        }
    }
    /**
     获取搜索结果
     */
    func getSearchResult(keyword: String, page:Int = 1, newSearch:Bool = true) async throws{
//        print("feint-debug keyword: \(keyword) page: \(page)")
        let originUrl = self.SEARCH_URL+"keyword=\(keyword)&search_type=video&page=\(page)"
        let safeUrl = originUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = safeUrl, let url = URL(string:url) else {
            return
        }
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        do {
            let json = try JSON(data: data)
            // 搜索成功
            if json["code"] == 0 {
                let data = json["data"]
                let results = data["result"].array
                var searchList:[VideoItem] = []
                results?.forEach({ result in
                    let video = result
                    let sourcePic = video["pic"].string!
                    if var title = video["title"].string {
                        title = title.replacingOccurrences(of: "<em class=\"keyword\">", with: "")
                        title = title.replacingOccurrences(of: "</em>", with: "")
                        let item = VideoItem(title: title, mainImage: UrlUtils.toSafeUrl(url: sourcePic),
                                             author: video["author"].string!, face: UrlUtils.toSafeUrl(url: video["upic"].string!),
                                             avid: video["aid"].int!, bvid: video["bvid"].string!)
                        searchList.append(item)
                    }
                   
                })
                if searchList.count > 0 {
                    let _sc = searchList
                    DispatchQueue.main.async {
                        if newSearch {
                            self.videoList.removeAll()
                        }
                        self.videoList.append(contentsOf: _sc)
                        self.regionPage = page
                    }
                }
                    
            }
            
        }catch {
            print("\(error)")
        }
    }
}

extension RandomAccessCollection where Self.Element: Identifiable {
    // 判断列表是否滚动到最后一个元素
    func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        guard let itemIndex = firstIndex(where: { $0.id.hashValue == item.id.hashValue }) else {
            return false
        }
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }
}
