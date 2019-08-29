//
//  YJSQLiteManager.swift
//  FMDBDemo
//
//  Created by 杨永杰 on 2019/8/28.
//  Copyright © 2019年 YYongJie. All rights reserved.
//

import Foundation
import FMDB

/// SQLite 管理器
/**
 1. 数据库本质上就是沙河中的一个文件，首先需要创建并且打开数据库
    - 使用 FMDB 队列创建
 2. 创建数据表
 3. 增删改查
 
 提示：数据库开发，程序代码几乎都是一致的，区别在 SQL
 
 */
class YJSQLiteManager {
    
    /// 单例
    static let shared = YJSQLiteManager()
    
    /// 数据库队列
    let queue: FMDatabaseQueue
    
    /// 构造函数
    private init() {
        
        /// 数据库的全路径 - path
        let dbName = "status.db"
        var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent(dbName )
        
        print("path = " + path)
        
        // 创建数据库队列
        queue = FMDatabaseQueue(path: path)!
        
        // 创建表
        createTable()
    }
}


// MARK: - 微博数据操作
extension YJSQLiteManager {
    
    /// 从数据库加载微博数据
    ///
    /// - Parameters:
    ///   - userId: 用户id
    ///   - since_id: 返回 id 比 since_id 大的微博
    ///   - max_id: 返回 id 小于或等于 max_id 的微博
    /// - Returns: 微博的字典的数组，将数据库中 status 二进制 序列化，转换为字典
    func loadStauts(userId: String, since_id: Int64 = 0, max_id: Int64 = 0) -> [[String: String]] {
        
        // 1. 准备 sql
        var sql = "SELECT statusId, userId, status FROM T_Status \n"
        sql += "WHERE userId = \(userId) \n"
        
        // 上拉/下拉
        if since_id > 0 {
            sql += "AND statusId > \(since_id) \n"
        } else if max_id > 0 {
            sql += "AND statusId < \(max_id) \n"
        }
        
        sql += "ORDER BY statusId DESC LIMIT 20;"
                
        
        // 2. 执行 sql
        // 遍历数组，将z数组中 status 反序列化成字典
        let array = execRecordSet(sql: sql)
        var result = [[String: String]]()
        
        for dict in array {
            
            // 反序列化
            guard let jsonData = dict["status"] as? Data,
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String]
                else {
                continue
            }

            // 追加到数组
            result.append(json ?? [:])
        }
        
        return result
    }
    
    /// 新增或者修改微博数据（没有就添加，有就更新）
    ///
    /// - Parameters:
    ///   - userId: 当前登录用户的id
    ///   - array: 从网络获取的 字典数组
    func updateStatus(userId: String, array: [[String: String]]) {
        
        /// 1. 准备 sql
        /**
         statusId: 要保存的微博代号
         userId: 当前登录用户id
         status: 完整的微博字典 json 二进制数据
         */
        let sql = "INSERT OR REPLACE INTO T_Status (statusId, userId, status) VALUES (?, ?, ?);"
        
        /// 2. 执行 sql
        queue.inTransaction { (db, rollback) in
            
            // 遍历素组，逐条插入微博数据
            for dict in array {
                
                // 从字典中获取 微博代号，将字典序列化成二进制数据
                guard let statusId = dict["idstr"],
                    let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                    else {
                        continue
                }

                // 执行 sql
                if db.executeUpdate(sql, withArgumentsIn: [statusId, userId, jsonData]) == false {

                    // 需要回滚 在 OC 中 *rollback = YES;
                    // 操作不成功，回滚到初始状态
                    rollback.pointee = true
                    break
                }
            }
        }
    }
}

// MARK: - 创建数据表及其它私有方法
extension YJSQLiteManager {
    
    /// 执行一个 sql
    ///
    /// - Parameter sql: sql
    /// - Returns: 字典数组
    func execRecordSet(sql: String) -> [[String: Any]] {
        
        /// 结果数组
        var result = [[String: Any]]()
        
        // 执行 sql - 查询数据，不修改数据，所以不需要 开启事务！
        // 事务的目的，是为了保证数据的有效性，一旦失败，回滚到初始化转态！
        queue.inDatabase { (db) in
            
            guard let rs = db.executeQuery(sql, withArgumentsIn: []) else {
                return
            }
            
            // 遍历结果集合
            while rs.next() {

                // 1> 列数
                let colCount = rs.columnCount
                
                // 2> 遍历所有列
                for col in 0..<colCount {

                    // 3> 列名 - key，值 - value
                    guard let name = rs.columnName(for: col),
                        var value = rs.object(forColumnIndex: col) else {
                            continue
                    }
                    
                    // 4> 追加结果
                    result.append([name: value])
                }
            }
        }
        
        return result
    }
    
    
    /// 创建数据表
    func createTable() {
        // 1. SQL
        guard let path = Bundle.main.path(forResource: "status", ofType: "sql"),
        let sql = try? String(contentsOfFile: path) else {
            return
        }
    
        // 2. 执行 sql - FMDB 的内部队列：串行队列，同步执行
        // 可以保证同一时间，只有一个任务操作数据库，从而保证数据库的读写安全！
        queue.inDatabase { (db) in
            
            if db.executeStatements(sql) == true {
                print("创表成功")
            } else {
                print("创表失败")
            }
        }
    
        print("over")
    }
}
