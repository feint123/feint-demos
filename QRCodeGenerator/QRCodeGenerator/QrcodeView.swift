//
//  QrcodeView.swift
//  EasyEdit
//
//  Created by feint on 2023/2/19.
//

import SwiftUI
import QRCode
import CompactSlider
import UniformTypeIdentifiers
import PhotosUI
import UIKit

struct QrcodeView: View {
    
    static var DEFAULT_QRCODE_WIDTH: CGFloat = 100
    static var DEFAULT_REAL_WIDTH: Double = 512.0
    private static var DEFAULT_PHOTO = Photo(image: Image(uiImage: UIImage(cgImage: QRCode.Document(utf8String: "", errorCorrection: .low).cgImage(CGSize(width: 1, height: 1))!)),caption: "分享二维码")
    
    // 二维码输入
    @State private var qrInput: String = ""
    
    @State private var photo: Photo = DEFAULT_PHOTO
    
    // 二维码内容
    @State private var qrStr: String = ""
    // 二维码尺寸
    @SceneStorage("QrcodeView.qrWidth") private var qrWidth: Double = DEFAULT_REAL_WIDTH
    // 二维码颜色
    @State private var qrColor: Color = .black
    //  二维码icon
    @State private var qrIcon: UIImage?
    // 当前选择的照片
    @State private var selectedPhoto: PhotosPickerItem?
    // 是否展示复制成功弹窗
    @State private var showCopyPop: Bool = false
    // 当前选择的二维码中心的icon形状
    @State private var selectShape: QRCodeIconShape = .rect
    //  qrcode预览界面的宽度
    @SceneStorage("QrcodeView.photoPreviewWidth") private var photoPreviewWidth: Double = DEFAULT_QRCODE_WIDTH * 1.25
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    var useCompactLayout: Bool {
        get{
            sizeClass == .compact
        }
    }
    
    var body: some View {
        Group {
            // ipad 和 ios 使用不同的布局视图
            if useCompactLayout {
                NavigationStack {
                    controlViews
                        .padding(.leading)
                        .padding(.trailing)
                }
            } else {
                NavigationSplitView {
                    controlViews
                        .padding(.horizontal)
                } detail: {
                    qrCodePreview
                        .padding()
                        .padding(.horizontal)
                        .capsule()
                        .overlay(alignment: .topTrailing) {
                            pasteBtn
                        }
                }
                .navigationSplitViewStyle(.balanced)
            }
        }
        .onChange(of: qrInput, perform: { _ in
            withAnimation {
                qrStr = ""
            }
        })
        .onChange(of: qrColor, perform: { _ in
            updateQrCode()
        })
        .onChange(of: qrWidth, perform: { _ in
            updateQrCode()
            withAnimation {
                // 对尺寸的变化限制在1～1.5之间
                // 对于ipad设备适当放宽尺寸的变化
                photoPreviewWidth = QrcodeView.DEFAULT_QRCODE_WIDTH * (1 + (qrWidth / 128) / (useCompactLayout ? 16 : 4))
            }

        })
        .onChange(of: qrIcon, perform: { newValue in
            updateQrCode()
        })
        .onChange(of: selectShape, perform: { newValue in
            updateQrCode()
        })
    }
    /**
     二维码预览视图
     */
    @ViewBuilder
    @MainActor
    var qrCodePreview: some View {
        HStack {
                if qrStr.isEmpty {
                    Image(systemName: "qrcode")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.secondary.opacity(0.3))
                } else {
                  
                    photo.image
                        .resizable()
                        .frame(width: photoPreviewWidth, height: photoPreviewWidth)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                }
        }
    }
    
    @ViewBuilder
    @MainActor
    var pasteBtn: some View {
        if !qrStr.isEmpty {
            Button {
                UIPasteboard.general.image = ImageRenderer(content: photo.image).uiImage
                showCopyPop = true
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
                    .labelStyle(.iconOnly)
            }
            .offset(x: -8, y: 8)
            .foregroundColor(.secondary)
            .alert(isPresented: $showCopyPop) {
                Alert(title: Text("Copied To Clipboard"))
            }
        } else {
            EmptyView()
        }
    }
    
    /**
     控制面板的视图
     */
    @MainActor
    @ViewBuilder
    var controlViews: some View {
        ScrollView {
            Spacer()
                .frame(height: 20)
            
            // 二维码预览
            if useCompactLayout {
                qrCodePreview
                    .padding()
                    .frame(maxWidth: .infinity)
                    .capsule()
                    .overlay(alignment: .topTrailing) {
                        pasteBtn
                    }
            }
            
            
            
            //  控制二维码中心的icon图片
            HStack {
                PhotoImage(selectedPhoto: $selectedPhoto) { uiImage in
                    withAnimation {
                        qrIcon = uiImage
                    }
                }
            
                if qrIcon != nil {
                    Picker(selection: $selectShape) {
                        Label("Rectangle" ,systemImage: "squareshape")
                            .tag(QRCodeIconShape.rect)
                        
                        Label("RoundedRectangle" ,systemImage: "rectangle.roundedtop")
                            .tag(QRCodeIconShape.rounded)
                        
                        Label("Circle" ,systemImage: "circle")
                            .tag(QRCodeIconShape.circle)
                        
                    } label: {
                        Text("Choose a shape")
                    }
                    .pickerStyle(.inline)
                    .frame(maxHeight: 80)
                    .capsule()
                }
            }
            
            Spacer()
                .frame(height: 20)
            
            // 二维码内容的编辑框
            HStack {
                TextField("", text: $qrInput, prompt: Text("Please input QR Code message").foregroundColor(.secondary).font(.body))
                    .font(.title2)
                    .submitLabel(.done)
                if !qrInput.isEmpty {
                    Button {
                        qrInput = ""
                    } label: {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }
            .normalPadding()
            .capsule()
            
            // 二维码尺寸调节
            CompactSlider(value: $qrWidth, in: 128...1024, step: 128) {
                HStack {
                    Text("Width").foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(qrWidth)) px").foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
            }
            .compactSliderStyle(.custom)
            
            Spacer()
                .frame(height: 20)
            ToolsGroupView {
                ColorPicker(selection: $qrColor) {
                }
                .normalPadding()
                .background(qrColor)
                .capsule()
                // 常用颜色面板
                ColorPanelView(selectColor: $qrColor)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                navigationItems
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                bottomBarItems
            }
        }
        .navigationTitle("QR Code")
        .navigationBarTitleDisplayMode(.inline)
    }
    /**
     导航栏工具栏
     */
    @ViewBuilder
    var navigationItems: some View {
        // 二维码分享按钮
        ShareLink(item: photo.image,
                  preview: SharePreview(photo.caption, image: photo.image)
        )
        .disabled(qrStr.isEmpty)
        
    }
    /**
     底部工具栏
     */
    @ViewBuilder
    var bottomBarItems: some View {
        // 打开系统图库选择二维码icon图片
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Label("icon", systemImage: "photo")
        }
       
        Spacer()
        
        // 生成二维码的按钮
        Button {
            withAnimation {
                qrStr = qrInput
            }
            updateQrCode()
            
        } label: {
            Label("Create QR Code", systemImage: "qrcode")
                .labelStyle(.titleAndIcon)
        }
        .disabled(qrInput.isEmpty)
        .buttonStyle(.borderedProminent)
        
        Spacer()
        
        // 从剪切板获取内容
        Button {
            if UIPasteboard.general.hasStrings {
                if let str = UIPasteboard.general.string {
                    qrInput = str
                }
            }
        } label: {
            Label("Paste", systemImage: "doc.on.clipboard")
            
        }

    }
    /**
     更新二维码
     */
    private func updateQrCode() {
        if let qrPhoto = createQrPhoto(self.qrStr) {
            photo = qrPhoto
        }
    }
    
    /**
     创建二维码图片
     */
    private func createQrPhoto(_ qrStr: String) -> Photo? {
        if qrStr.isEmpty {
            return nil
        }
        let doc = QRCode.Document(utf8String: qrStr)
        doc.design.shape.eye = QRCode.EyeShape.RoundedOuter()
        doc.design.shape.onPixels = QRCode.PixelShape.RoundedRect()
        doc.design.style.onPixels = QRCode.FillStyle.Solid(CGColor(red: qrColor.r, green: qrColor.g, blue: qrColor.b, alpha: qrColor.a))
        doc.design.shape.pupil = QRCode.PupilShape.RoundedRect()
        // 处理二维码icon到相关逻辑
        if let qrIcon = qrIcon {
            // 为icon选择相应的形状：矩形、圆角矩形、圆形
            switch selectShape {
            case .rect:
                doc.logoTemplate = QRCode.LogoTemplate(
                    path: CGPath(rect: CGRect(x: 0.35, y: 0.35, width: 0.30, height: 0.30), transform: nil),
                    inset: 2,
                    image: qrIcon.cgImage
                )
            case .rounded:
                doc.logoTemplate = QRCode.LogoTemplate(
                    path: CGPath(roundedRect: CGRect(x: 0.35, y: 0.35, width: 0.30, height: 0.30),
                                 cornerWidth: 0.1, cornerHeight: 0.1,transform: nil),
                    inset: 2,
                    image: qrIcon.cgImage
                )
            case .circle:
                doc.logoTemplate = QRCode.LogoTemplate(
                    path: CGPath(ellipseIn: CGRect(x: 0.35, y: 0.35, width: 0.30, height: 0.30), transform: nil),
                    inset: 2,
                    image: qrIcon.cgImage
                )
            }
           
        }
        
        return Photo(image: Image(uiImage: UIImage(cgImage: doc.cgImage(CGSize(width: qrWidth, height: qrWidth))!)),
                      caption: NSLocalizedString("Share QR Code", comment: "Share QR Code"))
    }
}
/**
 二维码icon形状枚举
 */
enum QRCodeIconShape {
    case rect, rounded, circle
}


struct Photo: Transferable, Identifiable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    public var image: Image
    public var caption: String
    public var id = UUID()
}

struct QrcodeView_Previews: PreviewProvider {
    static var previews: some View {
        QrcodeView()
    }
}
