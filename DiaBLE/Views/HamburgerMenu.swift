import SwiftUI


struct HamburgerMenu: View {

    @Binding var showingHamburgerMenu: Bool

    @State private var showingHelp = false
    @State private var showingAbout = false

    let credits = [
        "@bubbledevteam": "https://github.com/bubbledevteam?tab=repositories",
        "@captainbeeheart": "https://github.com/captainbeeheart?tab=repositories",
        "@cryptax": "https://github.com/cryptax?tab=repositories",
        "@dabear": "https://github.com/dabear?tab=repositories",
        "@ivalkou": "https://github.com/ivalkou?tab=repositories",
        "LibreMonitor": "https://github.com/UPetersen/LibreMonitor/tree/Swift4",
        "Loop": "https://github.com/LoopKit/Loop",
        "Nightguard": "https://github.com/nightscout/nightguard",
        "@travisgoodspeed": "https://github.com/travisgoodspeed?tab=repositories",
        "WoofWoof": "https://github.com/gshaviv/ninety-two",
        "xDrip+": "https://github.com/NightscoutFoundation/xDrip",
        "xDrip4iOS": "https://github.com/JohanDegraeve/xdripswift"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack{
                Spacer()
            }

            Button {
                withAnimation { showingHelp = true }
            } label: {
                Label("Help", systemImage: "questionmark.circle")
            }
            .padding(.leading, 6)
            .padding(.top, 20)
            .sheet(isPresented: $showingHelp) {
                NavigationView {
                    VStack(spacing: 40) {
                        VStack {
                            Text("Wiki").font(.headline)
                            Link("https://github.com/gui-dos/DiaBLE/wiki",
                                 destination: URL(string: "https://github.com/gui-dos/DiaBLE/wiki")!)
                        }
                        .padding(.top, 80)
                        Text("[ TODO ]")
                        Spacer()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Help")
                    .navigationViewStyle(.stack)
                    .toolbar {
                        Button {
                            withAnimation { showingHelp = false }
                        } label: {
                            Text("Close")

                        }
                    }
                    .onAppear() {
                        withAnimation { showingHamburgerMenu = false }
                    }
                    // TODO: click on any area
                    .onTapGesture {
                        withAnimation { showingHelp = false }
                    }
                }
            }

            Button {
                withAnimation { showingAbout = true }
            } label: {
                Label("About", systemImage: "info.circle")
            }
            .padding(.leading, 6)
            .sheet(isPresented: $showingAbout) {
                NavigationView {
                    VStack(spacing: 40) {
                        VStack {
                            Image(uiImage: getAppIcon()).resizable().frame(width: 100, height: 100)
                            // TODO: get AppIcon 1024x1024
                            // Image(uiImage: UIImage(named: "AppIcon60x60")!).resizable().frame(width: 100, height: 100)
                            Link("https://github.com/gui-dos/DiaBLE",
                                 destination: URL(string: "https://github.com/gui-dos/DiaBLE")!)
                        }

                        VStack {
                            Text("Contacts:")
                            Link(Data(base64Encoded: "Z3VpZG8uc29yYW56aW9AZ21haWwuY29t")!.string,
                                 destination: URL(string: "mailto:\(Data(base64Encoded: "Z3VpZG8uc29yYW56aW9AZ21haWwuY29t")!.string)")!)
                        }

                        VStack {
                            Text("Sponsor this project:")
                            Link("PayPal", destination: URL(string: "https://paypal.me/guisor")!)
                        }

                        VStack {
                            Text("Credits:")
                            ScrollView {
                                ForEach(credits.sorted(by: <), id: \.key) { name, url in
                                    Link(name, destination: URL(string: url)!)
                                        .padding(.horizontal, 32)
                                }
                            }
                            .frame(height: 70)
                        }

                        Text("??2021 Guido Soranzio")
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("About")
                    .navigationViewStyle(.stack)
                    .toolbar {
                        Button {
                            withAnimation { showingAbout = false }
                        } label: {
                            Text("Close")

                        }
                    }
                }
                .onAppear() {
                    withAnimation { showingHamburgerMenu = false }
                }
                // TODO: click on any area
                .onTapGesture {
                    withAnimation { showingAbout = false }
                }
            }

            Spacer()

        }
        .background(Color(.secondarySystemBackground))

        // TODO: swipe gesture
        .onLongPressGesture(minimumDuration: 0) {
            withAnimation(.easeOut(duration: 0.15)) { showingHamburgerMenu = false }
        }

    }
}


struct HamburgerMenu_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HamburgerMenu(showingHamburgerMenu: Monitor(showingHamburgerMenu: true).$showingHamburgerMenu)
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 180, height: 400))
        }
    }
}


// TODO: get AppIcon 1024x1024

// https://medium.com/macoclock/swift-how-to-get-current-app-icon-in-ios-2b3adbeedf16

/// - Returns: i. e. "AppIcon60x60.png"
func getAppIcon() -> UIImage {
    var appIcon: UIImage! {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return UIImage(named: "AppIcon") }
        return UIImage(named: lastIcon)
    }
    return appIcon
}
