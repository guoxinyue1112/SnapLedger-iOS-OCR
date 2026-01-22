//
//  ExpenseListView.swift
//  SnapLedger
//
//  Created by 郭心月 on 1/20/26.
//

import SwiftUI
import VisionKit // 必须引入，用于 DataScannerViewController 的硬件支持检查

struct ExpenseListView: View {
    // 实例化 ViewModel
    @StateObject var vm = ExpenseViewModel()
    
    // --- 新增状态变量：控制扫描页面显示 ---
    @State private var isShowingScanner = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.savedEntities) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.merchant ?? "未知商家")
                                .font(.headline)
                            Text(item.timestamp?.formatted(date: .abbreviated, time: .shortened) ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        // 格式化显示金额
                        Text("¥\(item.amount, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                }
                // --- 修复后的删除逻辑：显式调用 vm 中的删除方法 ---
                .onDelete { indexSet in
                    vm.deleteExpense(offsets: indexSet)
                }
            }
            .navigationTitle("最近账单")
            .toolbar {
                // 按钮组：建议使用 ToolbarItemGroup 或多个 ToolbarItem
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                    // 1. 扫描按钮
                    Button(action: {
                        // 检查设备是否支持 Vision Kit 扫描功能
                        if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                            isShowingScanner = true
                        } else {
                            // 这里可以添加一个 Alert 提示用户设备不支持
                            print("当前设备不支持扫描功能")
                        }
                    }) {
                        Label("扫描小票", systemImage: "camera.viewfinder")
                    }
                    
                    // 2. 原有的手动添加测试按钮
                    Button(action: {
                        vm.addExpense(merchant: "测试商店", amount: Double.random(in: 10...100))
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // --- 挂载扫描器视图 ---
            .sheet(isPresented: $isShowingScanner) {
                ScannerView { recognizedTexts in
                    handleScanResult(texts: recognizedTexts)
                }
            }
        }
    }
    
    // --- 处理扫描识别到的数据 ---
    private func handleScanResult(texts: [String]) {
        // 假设用户点击的是金额行
        guard let firstText = texts.first else { return }
        
        // 使用 ReceiptParser 解析文本（请确保你已创建该文件）
        let amount = ReceiptParser.extractAmount(from: firstText) ?? 0.0
        let merchant = ReceiptParser.extractMerchant(from: texts)
        
        // 保存到 Core Data
        vm.addExpense(merchant: merchant, amount: amount)
    }
}

// 预览预览
struct ExpenseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseListView()
    }
}
