//
//  ReceiptParser.swift
//  SnapLedger
//
//  Created by 郭心月 on 1/21/26.
//

import Foundation

struct ReceiptParser {
    
    /// 从识别到的字符串中提取金额
    /// - Parameter text: 扫描到的单行文本
    /// - Returns: 解析出的 Double 金额
    static func extractAmount(from text: String) -> Double? {
        // 1. 过滤掉货币符号、空格和逗号（处理 1,250.00 这种情况）
        let cleanedText = text.replacingOccurrences(of: "¥", with: "")
                              .replacingOccurrences(of: "$", with: "")
                              .replacingOccurrences(of: ",", with: "")
                              .trimmingCharacters(in: .whitespaces)

        // 2. 正则表达式：匹配 1-N 位数字 + 小数点 + 2位数字
        // 例如：12.50, 99.00
        let pattern = #"\d+\.\d{2}"#
        
        if let range = cleanedText.range(of: pattern, options: .regularExpression) {
            return Double(cleanedText[range])
        }
        
        // 3. 备选方案：尝试直接转换整数字符串（处理没有分位的小票）
        if let directDouble = Double(cleanedText) {
            return directDouble
        }
        
        return nil
    }
    
    /// 从文本数组中推断商家名
    static func extractMerchant(from texts: [String]) -> String {
        // 逻辑：通常点击的那行如果是商户名，它不应该包含太多数字
        guard let first = texts.first else { return "未知商家" }
        
        // 如果点击的文本包含金额特征，通常它不是商家名
        let containsNumber = first.rangeOfCharacter(from: .decimalDigits) != nil
        if containsNumber {
            return "扫描入账"
        }
        
        return first
    }
}
