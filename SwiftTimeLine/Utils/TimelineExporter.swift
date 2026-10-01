import SwiftUI
import AppKit

@MainActor
enum TimelineExporter {
    static func pngData(group: TimelineGroup, loc: Localization, scale: CGFloat = 2) -> Data? {
        let renderer = ImageRenderer(content: exportView(group: group, loc: loc))
        renderer.scale = scale
        guard let cgImage = renderer.cgImage else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .png, properties: [:])
    }

    static func pdfData(group: TimelineGroup, loc: Localization) -> Data? {
        let renderer = ImageRenderer(content: exportView(group: group, loc: loc))
        let data = NSMutableData()
        renderer.render { size, renderInContext in
            var mediaBox = CGRect(origin: .zero, size: size)
            guard let consumer = CGDataConsumer(data: data),
                  let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
                return
            }
            context.beginPDFPage(nil)
            renderInContext(context)
            context.endPDFPage()
            context.closePDF()
        }
        return data.length > 0 ? (data as Data) : nil
    }

    private static func exportView(group: TimelineGroup, loc: Localization) -> some View {
        TimelineExportView(group: group)
            .environment(\.loc, loc)
    }
}
