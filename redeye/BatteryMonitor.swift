import Combine
import Foundation
import IOKit.ps

struct BatteryState {
    let percentage: Int?
    let isCharging: Bool
    let timeToEmptyMinutes: Int?
}

class BatteryMonitor: ObservableObject {
    @Published private(set) var state = BatteryState(percentage: nil, isCharging: false, timeToEmptyMinutes: nil)

    private var timer: Timer?

    func start() {
        refresh()
        let t = Timer(timeInterval: 30, repeats: true) { [weak self] _ in self?.refresh() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func refresh() {
        state = readState()
    }

    private func readState() -> BatteryState {
        let snapshot = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let sourceList = IOPSCopyPowerSourcesList(snapshot).takeRetainedValue() as Array

        for ps in sourceList {
            let desc = IOPSGetPowerSourceDescription(snapshot, ps as CFTypeRef)
                .takeUnretainedValue() as? [String: Any]
            guard let info = desc,
                  (info[kIOPSTypeKey] as? String) == kIOPSInternalBatteryType
            else { continue }

            let current = info[kIOPSCurrentCapacityKey] as? Int ?? 0
            let max = info[kIOPSMaxCapacityKey] as? Int ?? 100
            let charging = info[kIOPSIsChargingKey] as? Bool ?? false
            let tte = info[kIOPSTimeToEmptyKey] as? Int

            return BatteryState(
                percentage: max > 0 ? (current * 100) / max : 0,
                isCharging: charging,
                timeToEmptyMinutes: (tte ?? -1) > 0 ? tte : nil
            )
        }
        return BatteryState(percentage: nil, isCharging: false, timeToEmptyMinutes: nil)
    }
}
