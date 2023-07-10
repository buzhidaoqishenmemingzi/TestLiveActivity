//
//  WidgetCircle.swift
//  testLiveActivity
//
//  Created by js on 2023/7/7.
//

import Foundation
import SwiftUI
import UIKit


@available(iOS 14.0, *)
struct WidgetCircle: View {

    var thickness: CGFloat = 12.0
    var width: CGFloat = 84.0
    var startAngle = -90.0
    var color: Color = Color(hex: "0069FF")
    @State var progress = 0.8
    
    var body: some View {
        VStack {
            ZStack {
                // 外环
                Circle()
                    .stroke(Color(hex: "FFFFFF",alpha: 0.08), lineWidth: thickness)
                // 内环
                RingShape(progress: progress, thickness: thickness)
                    .fill(color)
            }
            .frame(width: width, height: width, alignment: .center)
        }
    }
}

// 内环
@available(iOS 14.0, *)
struct RingShape: Shape {
    var progress: Double = 0.5
        var thickness: CGFloat = 12.0
        var startAngle: Double = -90.0

        var animatableData: Double {
            get { progress }
            set { progress = newValue }
        }

        func path(in rect: CGRect) -> Path {

            var path = Path()

            path.addArc(center: CGPoint(x: rect.width / 2.0, y: rect.height / 2.0), radius: min(rect.width, rect.height) / 2.0,startAngle: .degrees(startAngle),endAngle: .degrees(360 * progress + startAngle), clockwise: false)

            return path.strokedPath(.init(lineWidth: thickness, lineCap: .round))
        }
}


@available(iOS 14.0, *)
extension Color {
    init(hex: String, alpha: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: alpha
        )
    }
}


@available(iOS 14.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        WidgetCircle()
    }
}


