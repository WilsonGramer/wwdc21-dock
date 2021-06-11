import SwiftUI

struct Dock: View {
    let apps: [String]

    @State private var openApps: Set<String> = ["Finder"]
    @State private var bouncingApps: Set<String> = []
    @State private var hoveredApps: Set<String> = []
    @State private var appIconFrames: [String: CGRect] = [:]

    @State private var width = 0.0

    @State private var isHovering = false
    @State private var isAnimatingHover = false
    @State private var mouseLocation: CGPoint = .zero

    var body: some View {
        ZStack(alignment: .bottom) {
            self.background

            HStack(spacing: 6) {
                ForEach(self.apps, id: \.self) { app in
                    let isOpen = self.openApps.contains(app)

                    ZStack(alignment: .bottom) {
                        let (scale, padding) = self.hover(for: app)

                        ZStack(alignment: .bottom) {
                            self.appIconShadow(for: app)
                                .offset(y: 9)

                            Button(action: {
                                if isOpen {
                                    self.openApps.remove(app)
                                } else {
                                    let duration = 0.4
                                    let bounces = Int.random(in: 1...3) * 2

                                    DispatchQueue.main.asyncAfter(deadline: .now() + duration * Double(bounces) - 0.15) {
                                        self.bouncingApps.remove(app)
                                        self.openApps.insert(app)
                                    }

                                    withAnimation(.easeInOut(duration: duration).repeatCount(bounces, autoreverses: true)) {
                                        _ = self.bouncingApps.insert(app)
                                    }
                                }
                            }) {
                                let bouncing = self.bouncingApps.contains(app)

                                self.appIcon(for: app)
                                    .shadow(radius: 4, y: 2)
                                    .offset(y: bouncing ? -20 : 2)
                            }
                            .buttonStyle(AppIconButtonStyle())
                            .observingFrame(in: .named("dock")) { frame in
                                if self.appIconFrames[app] == nil {
                                    self.appIconFrames[app] = frame
                                }
                            }
                        }
                        .scaleEffect(scale, anchor: .bottom)
                        .padding(.horizontal, padding)
                        .onHover { hovering in
                            if hovering {
                                self.hoveredApps.insert(app)
                            } else {
                                self.hoveredApps.remove(app)
                            }
                        }
                        .overlay(Group {
                            if self.hoveredApps.contains(app) {
                                let background = Color(.controlBackgroundColor).opacity(0.75)

                                VStack(spacing: 0) {
                                    Text(app)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(background))

                                    Image(systemName: "arrowtriangle.down.fill")
                                        .resizable()
                                        .foregroundColor(background)
                                        .frame(width: 10, height: 5)
                                }
                                .offset(y: -80)
                            }
                        })

                        self.openIndicator
                            .opacity(isOpen ? 1 : 0)
                    }
                }
            }
            .padding([.horizontal, .bottom], 12)
            .observingSize { size in
                if self.isAnimatingHover {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        self.width = size.width
                    }
                } else {
                    self.width = size.width
                }
            }
        }
        .coordinateSpace(name: "dock")
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                self.isHovering = hovering
                self.isAnimatingHover = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.isAnimatingHover = false
            }
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { event in
                self.mouseLocation = NSApp.keyWindow!.mouseLocationOutsideOfEventStream

                return event
            }
        }
    }

    var background: some View {
        HStack {
            Spacer()

            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(.white.opacity(0.65))

                Rectangle().fill(.black.opacity(0.3)).frame(height: 5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(width: self.width, height: 68)

            Spacer()
        }
        .rotation3DEffect(.degrees(55), axis: (x: 1, y: 0, z: 0))
        .offset(y: 14)
        .shadow(radius: 24)
    }

    func appIcon(for app: String) -> some View {
        Image(app)
            .resizable()
            .antialiased(true)
            .interpolation(.high)
            .scaledToFit()
            .frame(width: 54, height: 54)
    }

    func appIconShadow(for app: String) -> some View {
        VStack { // intentional to reset frame
            self.appIcon(for: app)
                .blur(radius: 1.25)
                .opacity(0.2)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .frame(height: 8, alignment: .top)
                .clipped()
        }
    }

    var openIndicator: some View {
        Rectangle()
            .fill(.white)
            .overlay(Rectangle().strokeBorder(.blue.opacity(0.3), lineWidth: 0.5).blur(radius: 0.25))
            .frame(width: 10, height: 3)
            .offset(y: 12)
            .shadow(color: .white, radius: 2)
            .shadow(color: .white, radius: 3)
    }

    func hover(for app: String) -> (scale: CGFloat, padding: CGFloat) {
        let distance: CGFloat = {
            guard let frame = self.appIconFrames[app], self.isHovering else {
                return 0
            }

            let distance = abs(self.mouseLocation.x - frame.maxX)

            return distance <= 200 ? (200 - distance) / 200 : 0
        }()

        return (
            scale: 1 + distance / 1.5,
            padding: 18 * distance
        )
    }
}

struct AppIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.3 : 0)
    }
}
