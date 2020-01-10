//
//  Classes.swift
//  Tag
//
//  Created by Eugene L. on 7/1/20.
//  Copyright © 2020 ARandomDeveloper. All rights reserved.
//

import Foundation

class Receipt: Codable {
    
    struct ReceiptItem: Codable {
        
        var ItemName: String
        var ItemQty: Int
        var ItemSubTotal: Double
        
        init(Name: String, Qty: Int, SubTotal: Double) {
            
            ItemName = Name
            ItemQty = Qty
            ItemSubTotal = SubTotal
            
        }
        
    }
    
    var ReceiptStoreName: String
    var ReceiptTotal: Double
    var ReceiptItems: [ReceiptItem]
    
    init(StoreName: String, GrandTotal: Double, Items: [ReceiptItem]) {
        
        ReceiptStoreName = StoreName
        ReceiptTotal = GrandTotal
        ReceiptItems = Items
        
    }
    
    func HasText(text: String) -> Bool {
        
        if ReceiptStoreName.uppercased().contains(text.uppercased()) { return true }
        
        for item in ReceiptItems {
            if item.ItemName.uppercased().contains(text.uppercased()) { return true }
        }
        
        return false
        
    }
    
}
