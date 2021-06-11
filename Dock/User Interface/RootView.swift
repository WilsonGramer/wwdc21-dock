import SwiftUI

struct RootView: View {
    let apps: [String]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Image("Wallpaper")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)

                HStack {
                    Spacer()

                    Dock(apps: self.apps)

                    Spacer()
                }
                .padding(.horizontal, 14)
            }
            .font(.custom("Lucida Grande", size: 14))
        }
    }
}
