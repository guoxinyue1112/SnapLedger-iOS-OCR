//
//  ExpenseListView.swift
//  SnapLedger
//
//  Created by 郭心月 on 1/20/26.
//

import SwiftUI

struct ExpenseListView: View {
    // 实例化 ViewModel
    @StateObject var vm = ExpenseViewModel()
    
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
            }
            .navigationTitle("最近账单")
            .toolbar {
                // 测试按钮：手动添加一条数据，观察列表是否自动刷新
                Button(action: {
                    vm.addExpense(merchant: "测试商店", amount: Double.random(in: 10...100))
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
