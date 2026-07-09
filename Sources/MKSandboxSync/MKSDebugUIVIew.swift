#if DEBUG
#if canImport(UIKit)

import SwiftUI
import UIKit

struct MKSDebugUIVIew: View {
    @State private var toastText: String? = nil
    @State private var disableToasText = false

    var body: some View {
        NavigationView {
            List {
                // TODO: 1.显示app Home和group的目录；2.显示Web console的地址，端口。其中端口支持修改。
            }
            .overlay(
                ZStack {
                    if let toastText = toastText {
                        Text(toastText)
                            .foregroundColor(.white)
                            .padding()
                            .background (
                                Color.black.opacity(0.6)
                                    .cornerRadius(8)
                            )
                    }
                }
            )
            .onChange(of: toastText) { newValue in
                guard disableToasText == false else { return }
                disableToasText = true
                if newValue != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        toastText = nil
                        disableToasText = false
                    }
                }
            }
        }
        .navigationTitle("MKSDebugUIVIew")
    }
    
    var appGroupPaths: [(String, String)] {
        MKSandboxSync.shared.configuration.appGroupIdentifiers.map {
            ($0, FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: $0)?.path ?? "")
        }.filter { v in
            return !v.1.isEmpty
        }
    }
}

private struct MKSDebugUIText: View {
    @Binding var toastText: String?
    let displayText: String
    let value: String
    var body: some View {
        Text(displayText)
            .onTapGesture {
                UIPasteboard.general.string = value
                toastText = "复制成功"
            }
    }
}

#endif
#endif
