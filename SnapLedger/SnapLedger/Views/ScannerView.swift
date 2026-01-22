//
//  ScannerView.swift
//  SnapLedger
//
//  Created by 郭心月 on 1/21/26.
//

import SwiftUI
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    // 扫描成功后的回调，传回识别到的文本数组
    var onRecognized: ([String]) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // 开始扫描
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScannerView

        init(parent: ScannerView) {
            self.parent = parent
        }

        // 当用户点击屏幕上识别到的紫色高亮文字块时触发
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                // 传回点击的文本内容
                parent.onRecognized([text.transcript])
                parent.dismiss()
            default:
                break
            }
        }
    }
}
