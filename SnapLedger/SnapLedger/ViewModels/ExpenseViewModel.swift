//
//  ExpenseViewModel.swift
//  SnapLedger
//
//  Created by 郭心月 on 1/20/26.
//

import Foundation
import CoreData

class ExpenseViewModel: ObservableObject {
    // 1. 引用持久化容器
    private let container: NSPersistentContainer
    
    // 2. 发布的属性，当数据变化时，View 会自动刷新
    @Published var savedEntities: [ExpenseItem] = []
    
    init() {
        // 获取 AppDelegate 或 PersistenceController 中初始化的容器
        container = PersistenceController.shared.container
        fetchExpenses()
    }
    
    // MARK: - 数据操作
    
    // 从 Core Data 加载数据
    func fetchExpenses() {
        let request = NSFetchRequest<ExpenseItem>(entityName: "ExpenseItem")
        
        // 按时间倒序排列（最新的在前面）
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseItem.timestamp, ascending: false)]
        
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("读取 Core Data 出错: \(error)")
        }
    }
    
    // 添加数据（为 OCR 识别后的存储做准备）
    func addExpense(merchant: String, amount: Double) {
        let newExpense = ExpenseItem(context: container.viewContext)
        newExpense.id = UUID()
        newExpense.merchant = merchant
        newExpense.amount = amount
        newExpense.timestamp = Date()
        
        saveData()
    }
    
    // --- 新增：删除数据方法 ---
    func deleteExpense(offsets: IndexSet) {
        // 1. 根据索引找到对应的实体对象
        offsets.map { savedEntities[$0] }.forEach { entity in
            // 2. 从上下文中删除
            container.viewContext.delete(entity)
        }
        
        // 3. 保存并刷新
        saveData()
    }
    
    // 保存并刷新数据
    private func saveData() {
        do {
            try container.viewContext.save()
            fetchExpenses() // 保存成功后重新拉取，确保 UI 同步
        } catch let error {
            print("保存 Core Data 出错: \(error)")
        }
    }
}
