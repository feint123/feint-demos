//
//  VideoCardView.swift
//  my-bilibili
//
//  Created by feint on 2022/12/4.
//

import Foundation

import SwiftUI

struct VideoCardView: View {
    @Binding var videoItem:VideoItem
    @State var hoverTitle = false
    var body: some View {
        HStack(alignment: .center){
            AsyncImage(url: URL(string: videoItem.mainImage)) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "photo").resizable()
            }
            .scaledToFill()
            .frame(width: 64, height: 64)
            .cornerRadius(4)
            
            VStack(alignment: .leading){
            
                Text(videoItem.title)
                    .foregroundColor(hoverTitle ? .pink : .primary)
                    .font(.headline)
                    .lineLimit(2)
                    .onHover { hover in
                        withAnimation(.spring()) {
                            hoverTitle = hover
                        }
                    }
                HStack {
                    AsyncImage(url: URL(string:videoItem.face)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "dpad.up.fill")
                    }.frame(width: 18, height: 18)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.primary, lineWidth: 0.5))
                    Text(videoItem.author)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            
        }
    }
}

struct VideoCardView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCardView(videoItem: Binding.constant(VideoItem.defaultItem))
    }
}
