//
//  LiveactivityDataManager.swift
//  testLiveActivity
//
//  Created by js on 2023/7/6.
//

import Foundation
import ActivityKit

struct TestWidgetAttributes: ActivityAttributes {
    
    public typealias TestWidgetState = ContentState
    //可变参数（动态参数）
    public struct ContentState: Codable, Hashable {
        var dataModel: TestLADataModel
    }
    
    //不可变参数 (整个实时活动都不会改变的参数)
    //var name: String
}

@objc public class TestLADataModel: NSObject, Codable {
    @objc var idString : String = ""
    @objc var nameDes : String = ""
    @objc var contentDes : String = ""
    @objc var completedNum : Int//已完成人数
    @objc var notCompletedNum : Int//未完成人数
    var allPeopleNum : Int {
        get {
            return completedNum + notCompletedNum
        }
    }
    var progress : Double { //完成的进度,由 unPayerNum / allPayerNum 得来
        get {
            var tmpProgress = 0.0
            if allPeopleNum > 0 {
                tmpProgress = Double(completedNum) / Double(allPeopleNum);
            }
            return tmpProgress
        }
    }
    var progressDes : String {
        get {
            if allPeopleNum > 0 {
                return "\(completedNum)/\(allPeopleNum)"
            } else {
                return "0"
            }
        }
    }
    @objc var progressStatus : Int = 0
    @objc var statusIconName : String {//状态图标(大视图右侧)
        get {
            var name = "la_detail"
            if (progressStatus == 0) {
                //未完成
                name = "\(name)_pending"
            } else if (progressStatus == 1) {
                //已全部完成
                name = "\(name)_complete"
            } else if (progressStatus == 2) {
                //已关闭
                name = "\(name)_closed"
            } else {
                name = "\(name)_failed"
            }
            
            if languageIsCN {
                name = "\(name)_cn"
            } else {
                name = "\(name)_en"
            }
            return name
        }
    }
    var statusString : String {//状态描述,(小视图右侧的描述文案,内容取自statusIconName中的文字)
        get {
            var str = ""
            if languageIsCN {
                if (progressStatus == 0) {
                    str = ""
                } else if (progressStatus == 1) {
                    str = "已收齐"
                } else if (progressStatus == 2) {
                    str = "已关闭"
                } else {
                    //name = "\(name)_failed"
                    str = "已失效"
                }
            } else {
                if (progressStatus == 0) {
                    str = ""
                } else if (progressStatus == 1) {
                    str = "COMPLETE"
                } else if (progressStatus == 2) {
                    str = "CLOSED"
                } else {
                    str = "FAILED"
                }
            }
            return str
        }
    }
    @objc var languageIsCN : Bool = true
    
    public override init() {
        self.nameDes = ""
        self.contentDes = ""
        self.completedNum = 0
        self.notCompletedNum = 0
        self.progressStatus = 0
        self.languageIsCN = true
        super.init()
    }
    
    /// 便利构造
    @objc convenience init(nameDes: String, contentDes: String, completedNum: Int, notCompletedNum: Int, progressStatus: Int, languageIsCN: Bool) {
        self.init()
        self.nameDes = nameDes
        self.contentDes = contentDes
        self.completedNum = completedNum
        self.notCompletedNum = notCompletedNum
        self.progressStatus = progressStatus
        self.languageIsCN = languageIsCN
    }
    
}


@available(iOS 16.2, *)
@objc public class TestLAManager : NSObject {

    static let _sharedInstance: TestLAManager = TestLAManager()

    @objc public class func sharedInstance() -> TestLAManager {
        return TestLAManager._sharedInstance
    }

    /// 开启一个实时活动
    /// - Parameter dataModel: dataModel
    /// - Returns: 活动对应的通知token,可为空
    @objc public func startActivity(dataModel:TestLADataModel) {
        if !isOpenLiveActivity() {
            //不支持实时活动
            //
            return
        }

        if checkIsActivityIsLiving(idString: dataModel.idString) {
            //当前id仍处于存活状态
            return
        }

        let attributes = TestWidgetAttributes()
        let initialConetntState = TestWidgetAttributes.TestWidgetState(dataModel: dataModel)
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialConetntState, staleDate: nil),
              pushType: .token
            )
            //更新缓存
            updateActivityState(id:dataModel.idString, activityId: activity.id)
            //判断启动成功后，获取推送令牌 ，发送给服务器，用于远程推送Live Activities更新
            //不是每次启动都会成功，当已经存在多个Live activity时会出现启动失败的情况
            print("请求开启实时活动: \(activity.id)")

            Task {
                for await pushToken in activity.pushTokenUpdates {
                    let pushTokenString = pushToken.reduce("") { $0 + String(format: "%02x", $1) }
                    pushTokenDidUpdate(pushTokenString, pushToken);
                }
            }
        } catch (let error) {
            print("请求开启实时出错: \(error.localizedDescription)")
        }
    }


    @objc public var pushTokenDidUpdate = {(token: String, data: Data) -> () in
        //外部回调
    }

    /// 更新一个实时活动
    /// - Parameter dataModel: model
    @objc public func updateActivity(dataModel:TestLADataModel) {
        if !isOpenLiveActivity() {
            //不支持实时活动
            return
        }
        if !checkIsActivityIsLiving(idString: dataModel.idString) {
            //当前id未仍处于存活状态,不予更新
            return
        }

        Task {
            let updateState = TestWidgetAttributes.TestWidgetState(dataModel: dataModel)
            for activity in Activity<TestWidgetAttributes>.activities where activity.content.state.dataModel.idString == dataModel.idString {

                let alertConfig = AlertConfiguration(
                    title: "\(dataModel.nameDes) has taken a critical hit!",
                    body: "Open the app and use a potion to heal \(dataModel.nameDes)",
                    sound: .default
                )

                await activity.update(
                    ActivityContent<TestWidgetAttributes.ContentState>(
                        state: updateState,
                        staleDate: nil
                    ),
                    alertConfiguration: alertConfig
                )
                //更新缓存
                updateActivityState(id:dataModel.idString, activityId: activity.id)
                print("更新实时活动: \(activity.id)")
            }
        }
    }

    ///结束一个实时活动
    @objc public func stopActivity (idString:String) {
        Task {
            for activity in Activity<TestWidgetAttributes>.activities where activity.content.state.dataModel.idString == idString {
                let finalContent = TestWidgetAttributes.ContentState(
                    dataModel: TestLADataModel()
                )
                let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
                await activity.end(
                    ActivityContent(state: finalContent, staleDate: nil),
                    dismissalPolicy: dismissalPolicy)
                removeActivityState(id: idString);
                print("结束实时活动: \(activity)")
            }
        }
    }

    /// 是否支持实施活动（开关是否打开）
    /// 如果没有灵动岛.但是支持通知中心的LA,此处也会返回true
    /// - Returns: 是否支持
    @objc public func isOpenLiveActivity ()-> Bool {
        if !ActivityAuthorizationInfo().areActivitiesEnabled {
            return false
        }
        return true
    }

    /// 获取实施活动列表
    @objc public func getLiveActivityList () {
        Task {
            for activity in Activity<TestWidgetAttributes>.activities {
                print("实时活动详情: id=\(activity.id) state=\(activity.activityState) content=\(activity.content)")
            }
        }
    }

    static let LACacheDicKey = "LACacheDicKey"

    /// 检查实时活动是否存活
    /// - Parameter requstId: 活动id
    /// - Returns: 是否存活
    @objc public func checkIsActivityIsLiving(idString:String) -> Bool {
        if let ids = UserDefaults.standard.value(forKey: TestLAManager.LACacheDicKey) as? [String: String] {
            // 本地缓存包含该商品ID，并且系统的Activity依旧存在
            if ids.keys.contains(idString) {
                for activity in Activity<TestWidgetAttributes>.activities where activity.id == ids[idString] {
                    return true
                }
            }
        }
        return false
    }
    
    /// 更新实时活动的缓存
    /// - Parameters:
    ///   - requstId: requstId
    ///   - activityId: activityId
    @objc public func updateActivityState(id: String, activityId: String) {
        var ids = [String: String]()
        if let tempIds = UserDefaults.standard.value(forKey: TestLAManager.LACacheDicKey) as? [String: String] {
            ids = tempIds
        }
        ids[id] = activityId
        UserDefaults.standard.set(ids, forKey: TestLAManager.LACacheDicKey)
    }
    
    /// 尝试获取实时活动的缓存id
    /// - Parameter requstId: requstId
    /// - Returns: description
    @objc public func getActivityState(id: String) -> String? {
        if let ids = UserDefaults.standard.value(forKey: TestLAManager.LACacheDicKey) as? [String: String] {
            return ids[id]
        }
        return nil
    }
    
    /// 移除实时活动的缓存id
    /// - Parameter requstId: requstId
    @objc public func removeActivityState(id: String) {
        if var ids = UserDefaults.standard.value(forKey: TestLAManager.LACacheDicKey) as? [String: String] {
            ids.removeValue(forKey: id)
            UserDefaults.standard.set(ids, forKey: TestLAManager.LACacheDicKey)
        }
    }
}




