import Foundation

final class Debouncer {
    private var workItem: DispatchWorkItem?

    func debounce(delay: TimeInterval = 0.6, action: @escaping () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem(block: action)
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }
}
