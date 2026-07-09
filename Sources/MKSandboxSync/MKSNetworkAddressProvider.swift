#if DEBUG
import Foundation

#if canImport(Darwin)
import Darwin
#endif

enum MKSNetworkAddressProvider {
    static func webHosts() -> [String] {
        var hosts = localIPv4Addresses()

        #if targetEnvironment(simulator)
        hosts.insert("127.0.0.1", at: 0)
        #endif

        return Array(NSOrderedSet(array: hosts)) as? [String] ?? hosts
    }

    private static func localIPv4Addresses() -> [String] {
        #if canImport(Darwin)
        var addresses: [String] = []
        var interfaces: UnsafeMutablePointer<ifaddrs>?

        guard getifaddrs(&interfaces) == 0, let firstInterface = interfaces else {
            return []
        }
        defer { freeifaddrs(interfaces) }

        var pointer: UnsafeMutablePointer<ifaddrs>? = firstInterface
        while let interface = pointer?.pointee {
            defer { pointer = interface.ifa_next }

            let flags = Int32(interface.ifa_flags)
            let isUp = (flags & IFF_UP) == IFF_UP
            let isRunning = (flags & IFF_RUNNING) == IFF_RUNNING
            let isLoopback = (flags & IFF_LOOPBACK) == IFF_LOOPBACK

            guard isUp, isRunning, !isLoopback else { continue }
            guard let address = interface.ifa_addr, address.pointee.sa_family == UInt8(AF_INET) else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let result = getnameinfo(
                address,
                socklen_t(address.pointee.sa_len),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            )

            guard result == 0 else { continue }
            let ip = String(cString: hostname)
            if !ip.isEmpty {
                addresses.append(ip)
            }
        }

        return addresses.sorted { lhs, rhs in
            score(ip: lhs) < score(ip: rhs)
        }
        #else
        return []
        #endif
    }

    private static func score(ip: String) -> Int {
        if ip.hasPrefix("192.168.") { return 0 }
        if ip.hasPrefix("10.") { return 1 }
        if ip.hasPrefix("172.") { return 2 }
        return 3
    }
}
#endif
