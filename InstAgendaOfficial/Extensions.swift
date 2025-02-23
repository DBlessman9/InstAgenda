//
//  Extensions.swift
//  InstAgendaOfficial
//
//  Created by Derald Blessman on 2/22/25.
//

import UIKit

extension UIImage {
    class func fromLayer(_ layer: CALayer) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: layer.bounds.size)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    static let shortTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
