//
//  PhotoImage.swift
//  EasyEdit
//
//  Created by feint on 2023/2/24.
//

import SwiftUI
import PhotosUI
import UIKit
struct PhotoImage: View {
    
    @Binding var selectedPhoto: PhotosPickerItem?
    
    @State var photoLoadState: PhotoLoadState = .empty
    
    var onLoaded: (UIImage?) -> Void
    
    var body: some View {
        // 根据图片的加载状态，返回不同的视图
        Group {
            switch photoLoadState {
            case .progress:
                ProgressView()
            case .failure:
                // todo an alert pop window
                EmptyView()
            case .success(let image):
                HStack {
                    image
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .frame(width: 80 - 16, height: 80 - 16)
                        .overlay(alignment: .topTrailing) {
                            Button {
                                withAnimation {
                                    photoLoadState = .empty
                                }
                                selectedPhoto = nil
                                onLoaded(nil)
                            } label: {
                                Label("Delete", systemImage: "xmark.square.fill")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.red)
                                    .font(.title3)
                            }
                            .onAppear {
                                if let uiImage = ImageRenderer(content: image.resizable()
                                    .scaledToFill()
                                    .clipShape(Rectangle())
                                    .frame(width: 256, height: 256)).uiImage {
                                    onLoaded(uiImage)
                                }
                            }
                        }
                        
                }
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .capsule()
                    
            case .empty:
                //  a placeholder
                EmptyView()
            }
        }
        .onChange(of: selectedPhoto) { newValue in
            if let photo = newValue {
                let _ = loadTransferable(from: photo)
                photoLoadState = .progress
            }
        }
    }
    /**
     加载图片
     */
    func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: PickerImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == selectedPhoto else {
                    print("Failed to get the selected item.")
                    return
                }
                
                switch result {
                case .success(let image?):
                    withAnimation {
                        photoLoadState = .success(image.image)
                    }
                case .success(nil):
                    photoLoadState = .empty
                case .failure(let error):
                    photoLoadState = .failure(error)
                }
            }
        }
    }
}

enum PhotoLoadState {
    case progress, failure(Error), success(Image), empty
}

enum TransferError: Error {
    case importFailed
}

struct PickerImage: Transferable {
    let image: Image
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
        #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(nsImage: nsImage)
            return PickerImage(image: image)
        #elseif canImport(UIKit)
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(uiImage: uiImage)
            return PickerImage(image: image)
        #else
            throw TransferError.importFailed
        #endif
        }
    }
}

struct PhotoImage_Previews: PreviewProvider {
    static var previews: some View {
        PhotoImage(selectedPhoto: .constant(nil)) { image in
            
        }
    }
}
