//
//  VideoInfoView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import Foundation
import SwiftUI

struct VideoInfoView: View {
    @EnvironmentObject var fetcher: BiliFetcher
    @State var isExpended = false
    var body: some View {
        VStack(alignment: .leading){
 
            Text(fetcher.videoDetail.title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .font(.title2)
                .foregroundColor(.primary)
            HStack{
                AsyncImage(url: URL(string: fetcher.videoDetail.upInfo.headImage)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }.frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.secondary, lineWidth: 1))
                Text(fetcher.videoDetail.upInfo.name).font(.subheadline)
            }
            
            Text(fetcher.videoDetail.introduce)
                .font(.footnote)
                .lineLimit(10)
                .foregroundColor(.secondary)
          
        }
    }
        
}

struct VideoInfoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoInfoView().environmentObject(BiliFetcher())
    }
}
