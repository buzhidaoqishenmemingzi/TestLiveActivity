//
//  demoWLiveActivity.swift
//  demoW
//
//  Created by js on 2023/7/6.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct demoWLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TestWidgetAttributes.self) { context in
            // 锁屏之后，显示的桌面通知栏位置，这里可以做相对复杂的布局
            let dataModel = context.state.dataModel
            
            ZStack{
//                LinearGradient(colors: [Color(hex: "16283B", alpha:0.2),Color(hex: "16283B", alpha:0.2)], startPoint: .leading, endPoint: .bottom)
                
                VStack(alignment: .leading, content: {
                    HStack (alignment: .center){
                        
                        VStack (alignment: .leading, content: {
                            Text(String(dataModel.nameDes))
                                .fontWeight(.bold)
                                .font(.title)
                                .foregroundColor(Color(hex: "FFFFFF"))
                                .minimumScaleFactor(0.1)
                            Text(String(dataModel.contentDes))
                                .fontWeight(.bold)
                                .font(.headline)
                                .foregroundColor(Color(hex: "FFFFFF"))
                                .minimumScaleFactor(0.1)
                        }).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        Spacer()
                        VStack (alignment: .leading, content: {
                            Image(dataModel.statusIconName).resizable().frame(width: 70, height: 70)
                            
                        }).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -5))
                    }
                }).padding(EdgeInsets(top: 15, leading: 15, bottom: 20, trailing: 15))
            }

        } dynamicIsland: { context in
            let dataModel = context.state.dataModel
            return DynamicIsland {
                /*
                 这里是长按灵动岛[扩展型]的UI
                 有四个区域限制了布局，分别是左、右、中间（硬件下方）、底部区域
                 */
                DynamicIslandExpandedRegion(.leading) {
                    //
                }
                DynamicIslandExpandedRegion(.trailing) {
                    
                    
                }
                DynamicIslandExpandedRegion(.center) {
                    
                }
                DynamicIslandExpandedRegion(.bottom) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 10, content: {
                            Text(String(dataModel.nameDes))
                                .fontWeight(.bold)
                                .font(.title)
                                .foregroundColor(Color(hex: "FFFFFF"))
                                .minimumScaleFactor(0.1)
                            Text(String(dataModel.contentDes))
                                .fontWeight(.bold)
                                .font(.headline)
                                .foregroundColor(Color(hex: "FFFFFF"))
                                .minimumScaleFactor(0.1)
                        })
                        Spacer()
                        HStack (alignment: .center){
                            Image(dataModel.statusIconName).resizable().frame(width: 70, height: 70)
                        }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: -10))
                    }.padding(EdgeInsets(top: 5, leading: 10, bottom: 10, trailing: 10))
                }
            } compactLeading: {
                // 这里是灵动岛[紧凑型]左边的布局
                HStack {
//                    Image("").resizable().frame(width: 30, height: 30)
                }
            } compactTrailing: {
                // 这里是灵动岛[紧凑型]右边的布局
                HStack {
                    Spacer(minLength: 1)
                    
                    
                    ZStack (alignment: .center){
                        if dataModel.progressStatus == 0 {
                            //pending
                            WidgetCircle(thickness: 2,width: 25,startAngle: 90,progress:dataModel.progress)
                            Text(String(dataModel.progressDes))
//                                .fontWeight(.bold)
                                .font(.system(size: 10))
                                .foregroundColor(Color(hex: "FFFFFF"))
                                .minimumScaleFactor(0.1)
                        } else if dataModel.progressStatus == 1 {
                            //completed
                            Text(String(dataModel.statusString))
                                .font(.callout)
                                .foregroundColor(Color(hex: "43974D"))
                                .minimumScaleFactor(0.1)
                        } else if dataModel.progressStatus == 2 {
                            //closed
                            Text(String(dataModel.statusString))
//                                .fontWeight(.bold)
                                .font(.callout)
                                .foregroundColor(Color(hex: "70767F"))
                                .minimumScaleFactor(0.1)
                        } else if dataModel.progressStatus == 3 {
                            //failed
                            Text(String(dataModel.statusString))
//                                .fontWeight(.bold)
                                .font(.callout)
                                .foregroundColor(Color(hex: "70767F"))
                                .minimumScaleFactor(0.1)
                        }
                        
                    }
                }
            } minimal: {
                // 这里是灵动岛[最小型]的布局(有多个任务的情况下，展示优先级高的任务，位置在右边的一个圆圈区域)
                // 这里是灵动岛[最小型]的布局(有多个任务的情况下，展示优先级高的任务，位置在右边的一个圆圈区域)
                ZStack (alignment: .center){
                    if dataModel.progressStatus == 0 {
                        //pending
                        WidgetCircle(thickness: 2,width: 25,startAngle: 90,progress:dataModel.progress)
                        Text(String(dataModel.progressDes))
                            .fontWeight(.bold)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "FFFFFF"))
                            .minimumScaleFactor(0.1)
                    } else if dataModel.progressStatus == 1 {
                        //completed
                        Text(String(dataModel.statusString))
                            .fontWeight(.bold)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "43974D"))
                            .minimumScaleFactor(0.1)
                    } else if dataModel.progressStatus == 2 {
                        //closed
//                        Label("Favorite Books", systemImage: "books.vertical")
//                            .labelStyle(.titleAndIcon)    // 标签风格为显示标题和图标
//                            .font(.largeTitle)            // 字体设置为largeTitle
                        Text(String(dataModel.statusString))
                            .fontWeight(.bold)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "70767F"))
                            .minimumScaleFactor(0.1)
                    } else if dataModel.progressStatus == 3 {
                        //failed
                        Text(String(dataModel.statusString))
                            .fontWeight(.bold)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "70767F"))
                            .minimumScaleFactor(0.1)
                    }
                    
                }
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

struct demoWLiveActivity_Previews: PreviewProvider {
    static let attributes = TestWidgetAttributes()
    static let dataModel = TestLADataModel(nameDes: "作业收录情况", contentDes: "收取中", completedNum: 9, notCompletedNum: 11, progressStatus: 0, languageIsCN: true)
    
    static let contentState = TestWidgetAttributes.TestWidgetState(dataModel: dataModel)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
