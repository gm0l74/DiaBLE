import Foundation
import SwiftUI


struct Monitor: View {
    @EnvironmentObject var app: AppState
    @EnvironmentObject var history: History
    @EnvironmentObject var settings: Settings

    @State var showingHamburgerMenu = false

    @State private var showingNFCAlert = false

    @State private var readingCountdown: Int = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {

            ZStack(alignment: .topLeading) {

                VStack {

                    Spacer()

                    VStack {

                        HStack {

                            VStack {
                                if app.lastReadingDate != Date.distantPast {
                                    Text(app.lastReadingDate.shortTime)
                                    Text("\(Int(Date().timeIntervalSince(app.lastReadingDate)/60)) min ago").font(.footnote)
                                } else {
                                    Text("---")
                                }
                            }.frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 12).foregroundColor(Color(.lightGray))

                            Text(app.currentGlucose > 0 ? "\(app.currentGlucose.units) " : "--- ")
                                .fontWeight(.black)
                                .foregroundColor(.black)
                                .padding(10)
                                .background(app.currentGlucose > 0 && (app.currentGlucose > Int(settings.alarmHigh) || app.currentGlucose < Int(settings.alarmLow)) ?
                                            Color.red : app.currentGlucose < 0 ? Color.orange : Color.blue)
                                .cornerRadius(5)

                            // TODO
                            Group {
                                if app.trendDeltaMinutes > 0 {
                                    VStack {
                                        Text("\(app.trendDelta > 0 ? "+ " : app.trendDelta < 0 ? "- " : "")\(app.trendDelta == 0 ? "???" : abs(app.trendDelta).units)")
                                            .fontWeight(.black)
                                        Text("\(app.trendDeltaMinutes) min").font(.footnote)
                                    }.frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 12)
                                } else {
                                    Text(LibreTrendArrow(rawValue: app.oopTrend)?.symbol ?? "---").font(.largeTitle).bold()
                                        .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 12)
                                }
                            }.foregroundColor(app.currentGlucose > 0 && (app.currentGlucose > Int(settings.alarmHigh) && app.trendDelta > 0 || app.currentGlucose < Int(settings.alarmLow)) && app.trendDelta < 0 ?
                                                .red : app.currentGlucose < 0 ? .orange : .blue)

                        }

                        Text("\(app.oopAlarm.replacingOccurrences(of: "_", with: " ")) - \(app.oopTrend.replacingOccurrences(of: "_", with: " "))")
                            .foregroundColor(.blue)

                        HStack {
                            Text(app.deviceState)
                                .foregroundColor(app.deviceState == "Connected" ? .green : .red)
                                .fixedSize()

                            if !app.deviceState.isEmpty && app.deviceState != "Disconnected" {
                                Text(readingCountdown > 0 || app.deviceState == "Reconnecting..." ?
                                     "\(readingCountdown) s" : "")
                                    .fixedSize()
                                    .font(Font.callout.monospacedDigit()).foregroundColor(.orange)
                                    .onReceive(timer) { _ in
                                        readingCountdown = settings.readingInterval * 60 - Int(Date().timeIntervalSince(app.lastReadingDate))
                                    }
                            }
                        }
                    }


                    Graph().frame(width: 31 * 7 + 60, height: 150)


                    VStack {

                        HStack(spacing: 12) {

                            if app.sensor != nil && (app.sensor.state != .unknown || app.sensor.serial != "") {
                                VStack {
                                    Text(app.sensor.state.description)
                                        .foregroundColor(app.sensor.state == .active ? .green : .red)

                                    if app.sensor.age > 0 {
                                        Text(app.sensor.age.shortFormattedInterval)
                                    }
                                }
                            }

                            if app.device != nil {
                                VStack {
                                    if app.device.battery > -1 {
                                        Text("Battery: ").foregroundColor(Color(.lightGray)) +
                                        Text("\(app.device.battery)%").foregroundColor(app.device.battery > 10 ? .green : .red)
                                    }
                                    if app.device.rssi != 0  {
                                        Text("RSSI: ").foregroundColor(Color(.lightGray)) +
                                        Text("\(app.device.rssi) dB")
                                    }
                                }
                            }

                        }.font(.footnote).foregroundColor(.yellow)

                        Text(app.status)
                            .font(.footnote)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)

                        NavigationLink(destination: Details()) {
                            Text("Details").font(.footnote).bold().fixedSize()
                                .padding(.horizontal, 4).padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 2))
                        }
                    }

                    Spacer()

                    Spacer()

                    HStack {

                        Button {
                            app.main.rescan()

                        } label: {
                            Image(systemName: "arrow.clockwise.circle").resizable().frame(width: 32, height: 32).padding(.bottom, 8).foregroundColor(.accentColor)
                        }

                        if (app.status.hasPrefix("Scanning") || app.status.hasSuffix("retrying...")) && app.main.centralManager.state != .poweredOff {
                            Button {
                                app.main.centralManager.stopScan()
                                app.main.status("Stopped scanning")
                                app.main.log("Bluetooth: stopped scanning")
                            } label: {
                                Image(systemName: "stop.circle").resizable().frame(width: 32, height: 32)
                            }.padding(.bottom, 8).foregroundColor(.red)
                        }

                    }

                }
                .multilineTextAlignment(.center)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("DiaBLE  \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)  -  Monitor")
                .toolbar {

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            withAnimation(.easeOut(duration: 0.15)) { showingHamburgerMenu.toggle() }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                        }
                    }

                    // FIXME: the NFC ToolbarItem makes the compiler unable to type-check this expression in reasonable time

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            if app.main.nfc.isAvailable {
                                app.main.nfc.startSession()
                            } else {
                                showingNFCAlert = true
                            }
                        } label: {
                            // FIXME: stacked image disappears in SwiftUI 3
                            // VStack(spacing: 0) {
                            // original: .frame(width: 39, height: 27
                            Image("NFC").renderingMode(.template).resizable().frame(width: 26, height: 18)
                            // Text("Scan").font(.footnote)
                            // }
                        }
                    }
                }
                .alert(isPresented: $showingNFCAlert) {
                    Alert(
                        title: Text("NFC not supported"),
                        message: Text("This device doesn't allow scanning the Libre."))
                }


                HamburgerMenu(showingHamburgerMenu: $showingHamburgerMenu)
                    .frame(width: 180)
                    .offset(x: showingHamburgerMenu ? 0 : -180)
            }
        }.navigationViewStyle(.stack)
    }
}


struct Monitor_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(AppState.test(tab: .monitor))
                .environmentObject(Log())
                .environmentObject(History.test)
                .environmentObject(Settings())
        }
    }
}
