import SwiftUI

extension View {
    func observingFrame(in coordinateSpace: CoordinateSpace = .global, update: @escaping (CGRect) -> Void) -> some View {
        self.background(GeometryReader { geometry in
            let frame = geometry.frame(in: coordinateSpace)

            Color.clear
                .onAppear { update(frame) }
                .onChange(of: frame, perform: update)
        })
    }

    func observingSize(update: @escaping (CGSize) -> Void) -> some View {
        self.background(GeometryReader { geometry in
            let size = geometry.size

            Color.clear
                .onAppear { update(size) }
                .onChange(of: size, perform: update)
        })
    }
}
