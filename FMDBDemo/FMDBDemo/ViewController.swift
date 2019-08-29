//
//  ViewController.swift
//  FMDBDemo
//
//  Created by 杨永杰 on 2019/8/28.
//  Copyright © 2019年 YYongJie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 模拟数据
        let array = [
            ["idstr" : "100", "text" : "微博-100 BvvB"],
            ["idstr" : "101", "text" : "微博-101 VV"],
            ["idstr" : "102", "text" : "微博-102 CC"],
            ["idstr" : "103", "text" : "微博-103"],
            ["idstr" : "104", "text" : "微博-104"],
            ["idstr" : "105", "text" : "微博-105 AA"],
            ["idstr" : "106", "text" : "微博-106"],
            ["idstr" : "107", "text" : "微博-107"],
            ["idstr" : "108", "text" : "微博-108"],
            ["idstr" : "109", "text" : "微博-109"],
            ["idstr" : "110", "text" : "微博-110"],
            ["idstr" : "111", "text" : "微博-111"],
            ["idstr" : "112", "text" : "微博-112"],
            ["idstr" : "113", "text" : "微博-113"],
            ["idstr" : "114", "text" : "微博-114"],
            ["idstr" : "115", "text" : "微博-115"],
            ["idstr" : "116", "text" : "微博-116"],
            ["idstr" : "117", "text" : "微博-117"],
            ["idstr" : "118", "text" : "微博-118"],
            ["idstr" : "119", "text" : "微博-119"],
            ["idstr" : "120", "text" : "微博-120"],
            ["idstr" : "121", "text" : "微博-121"],
            ["idstr" : "122", "text" : "微博-122"],
        ]
                
        YJSQLiteManager.shared.updateStatus(userId: "66", array: array)
    
        // 测试查询
       let _ = YJSQLiteManager.shared.execRecordSet(sql: "SELECT statusId, userId, status FROM T_Status")
        
        // 测试加载数据
        // 1> 进入系统第一次刷新
        _ = YJSQLiteManager.shared.loadStauts(userId: "88", since_id: 0, max_id: 0)
        // 2> 测试下拉数据
        _ = YJSQLiteManager.shared.loadStauts(userId: "88", since_id: 120, max_id: 0)
        // 3> 测试上拉拉数据
        _ = YJSQLiteManager.shared.loadStauts(userId: "88", since_id: 0, max_id: 110)
    }
    
}

