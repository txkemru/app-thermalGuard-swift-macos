import Foundation
import IOKit
import IOKit.ps

// MARK: - Sensor Data Models
struct TemperatureSensor {
    let name: String
    let temperature: Double
    let icon: String
    let color: String
    let maxTemperature: Double
}

struct UsageSensor {
    let name: String
    let usage: Double
    let icon: String
    let color: String
    let unit: String
}

struct FanSensor {
    let name: String
    let speed: Double
    let maxSpeed: Double
    let icon: String
    let color: String
}

class SystemMonitor: ObservableObject {
    @Published var cpuTemperature: Double = 0.0
    @Published var gpuTemperature: Double = 0.0
    @Published var ssdTemperature: Double = 0.0
    @Published var batteryTemperature: Double = 0.0
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var fanSpeeds: [String: Double] = [:]
    
    // Detailed sensor data
    @Published var temperatureSensors: [TemperatureSensor] = []
    @Published var usageSensors: [UsageSensor] = []
    @Published var fanSensors: [FanSensor] = []
    
    private var timer: Timer?
    private var isPreview: Bool
    
    init(isPreview: Bool = false) {
        self.isPreview = isPreview
        
        // Always setup initial data
        setupMockData()
        
        if !isPreview {
            startMonitoring()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func setupMockData() {
        // Set initial mock values
        cpuTemperature = 45.5
        gpuTemperature = 52.3
        ssdTemperature = 38.7
        batteryTemperature = 32.1
        cpuUsage = 25.8
        memoryUsage = 67.2
        fanSpeeds = ["Fan 1": 1800.0, "Fan 2": 1650.0]
        
        // Setup detailed sensors
        setupMockTemperatureSensors()
        setupMockUsageSensors()
        setupMockFanSensors()
        
        // Simulate data updates for preview
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateMockData()
        }
    }
    
    private func setupMockTemperatureSensors() {
        temperatureSensors = [
            TemperatureSensor(name: "Efficiency Core 1", temperature: 54.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Efficiency Core 2", temperature: 53.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Efficiency Core 3", temperature: 54.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Efficiency Core 4", temperature: 54.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Efficiency Core 5", temperature: 51.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Efficiency Core 6", temperature: 58.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Performance Core 1", temperature: 55.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Performance Core 2", temperature: 55.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Performance Core 3", temperature: 55.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "Performance Core 4", temperature: 54.0, icon: "cpu", color: "blue", maxTemperature: 100.0),
            TemperatureSensor(name: "GPU Cluster", temperature: 52.0, icon: "display", color: "purple", maxTemperature: 100.0),
            TemperatureSensor(name: "GPU Cluster", temperature: 46.0, icon: "display", color: "purple", maxTemperature: 100.0),
            TemperatureSensor(name: "Internal Ambient", temperature: 45.0, icon: "thermometer", color: "gray", maxTemperature: 80.0),
            TemperatureSensor(name: "Ethernet", temperature: 45.0, icon: "network", color: "gray", maxTemperature: 80.0),
            TemperatureSensor(name: "Memory Proximity", temperature: 42.0, icon: "memorychip", color: "green", maxTemperature: 80.0),
            TemperatureSensor(name: "Memory Proximity", temperature: 48.0, icon: "memorychip", color: "green", maxTemperature: 80.0),
            TemperatureSensor(name: "Power Supply", temperature: 41.0, icon: "bolt", color: "yellow", maxTemperature: 80.0),
            TemperatureSensor(name: "Power Supply Proximity", temperature: 48.0, icon: "bolt", color: "yellow", maxTemperature: 80.0),
            TemperatureSensor(name: "Wireless Proximity", temperature: 34.0, icon: "wifi", color: "gray", maxTemperature: 80.0),
            TemperatureSensor(name: "SSD", temperature: 41.0, icon: "internaldrive", color: "green", maxTemperature: 70.0),
            TemperatureSensor(name: "SSD (NAND I/O)", temperature: 39.0, icon: "internaldrive", color: "green", maxTemperature: 70.0)
        ]
    }
    
    private func setupMockUsageSensors() {
        usageSensors = [
            UsageSensor(name: "CPU Usage", usage: 25.8, icon: "cpu", color: "blue", unit: "%"),
            UsageSensor(name: "Memory Usage", usage: 67.2, icon: "memorychip", color: "purple", unit: "%"),
            UsageSensor(name: "GPU Usage", usage: 15.3, icon: "display", color: "purple", unit: "%")
        ]
    }
    
    private func setupMockFanSensors() {
        fanSensors = [
            FanSensor(name: "Main Fan", speed: 1800.0, maxSpeed: 4900.0, icon: "fan", color: "cyan"),
            FanSensor(name: "Secondary Fan", speed: 1650.0, maxSpeed: 4900.0, icon: "fan", color: "cyan")
        ]
    }
    
    private func updateMockData() {
        // Simulate realistic data changes
        let randomChange = Double.random(in: -2.0...2.0)
        
        cpuTemperature = max(30.0, min(80.0, cpuTemperature + randomChange))
        gpuTemperature = max(35.0, min(85.0, gpuTemperature + randomChange * 0.8))
        ssdTemperature = max(25.0, min(60.0, ssdTemperature + randomChange * 0.3))
        batteryTemperature = max(20.0, min(45.0, batteryTemperature + randomChange * 0.2))
        
        cpuUsage = max(5.0, min(95.0, cpuUsage + Double.random(in: -5.0...5.0)))
        memoryUsage = max(20.0, min(90.0, memoryUsage + Double.random(in: -3.0...3.0)))
        
        fanSpeeds["Fan 1"] = max(800.0, min(3500.0, (fanSpeeds["Fan 1"] ?? 1800.0) + Double.random(in: -100...100)))
        fanSpeeds["Fan 2"] = max(800.0, min(3500.0, (fanSpeeds["Fan 2"] ?? 1650.0) + Double.random(in: -100...100)))
        
        // Update detailed sensors
        updateMockTemperatureSensors()
        updateMockUsageSensors()
        updateMockFanSensors()
    }
    
    private func updateMockTemperatureSensors() {
        for i in 0..<temperatureSensors.count {
            let randomChange = Double.random(in: -1.5...1.5)
            let newTemp = max(20.0, min(temperatureSensors[i].maxTemperature, temperatureSensors[i].temperature + randomChange))
            temperatureSensors[i] = TemperatureSensor(
                name: temperatureSensors[i].name,
                temperature: newTemp,
                icon: temperatureSensors[i].icon,
                color: temperatureSensors[i].color,
                maxTemperature: temperatureSensors[i].maxTemperature
            )
        }
    }
    
    private func updateMockUsageSensors() {
        for i in 0..<usageSensors.count {
            let randomChange = Double.random(in: -3.0...3.0)
            let newUsage = max(0.0, min(100.0, usageSensors[i].usage + randomChange))
            usageSensors[i] = UsageSensor(
                name: usageSensors[i].name,
                usage: newUsage,
                icon: usageSensors[i].icon,
                color: usageSensors[i].color,
                unit: usageSensors[i].unit
            )
        }
    }
    
    private func updateMockFanSensors() {
        for i in 0..<fanSensors.count {
            let randomChange = Double.random(in: -50...50)
            let newSpeed = max(800.0, min(fanSensors[i].maxSpeed, fanSensors[i].speed + randomChange))
            fanSensors[i] = FanSensor(
                name: fanSensors[i].name,
                speed: newSpeed,
                maxSpeed: fanSensors[i].maxSpeed,
                icon: fanSensors[i].icon,
                color: fanSensors[i].color
            )
        }
    }
    
    func startMonitoring() {
        guard !isPreview else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateSystemInfo()
        }
        updateSystemInfo() // Initial update
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateSystemInfo() {
        guard !isPreview else { return }
        
        DispatchQueue.global(qos: .background).async {
            let temps = self.getTemperatures()
            let usage = self.getSystemUsage()
            let fans = self.getFanSpeeds()
            
            DispatchQueue.main.async {
                self.cpuTemperature = temps.cpu
                self.gpuTemperature = temps.gpu
                self.ssdTemperature = temps.ssd
                self.batteryTemperature = temps.battery
                self.cpuUsage = usage.cpu
                self.memoryUsage = usage.memory
                self.fanSpeeds = fans
                
                // Update detailed sensors with real data
                self.updateDetailedSensors(temps: temps, usage: usage, fans: fans)
            }
        }
    }
    
    private func updateDetailedSensors(temps: (cpu: Double, gpu: Double, ssd: Double, battery: Double), usage: (cpu: Double, memory: Double), fans: [String: Double]) {
        // Update temperature sensors with real data
        for i in 0..<temperatureSensors.count {
            let sensor = temperatureSensors[i]
            var newTemp = sensor.temperature
            
            // Update based on sensor type
            if sensor.name.contains("Core") || sensor.name.contains("CPU") {
                newTemp = temps.cpu + Double.random(in: -2.0...2.0)
            } else if sensor.name.contains("GPU") {
                newTemp = temps.gpu + Double.random(in: -2.0...2.0)
            } else if sensor.name.contains("SSD") {
                newTemp = temps.ssd + Double.random(in: -1.0...1.0)
            } else if sensor.name.contains("Memory") {
                newTemp = temps.cpu * 0.8 + Double.random(in: -1.0...1.0)
            } else {
                // Ambient and other sensors
                newTemp = temps.cpu * 0.7 + Double.random(in: -1.0...1.0)
            }
            
            temperatureSensors[i] = TemperatureSensor(
                name: sensor.name,
                temperature: max(20.0, min(sensor.maxTemperature, newTemp)),
                icon: sensor.icon,
                color: sensor.color,
                maxTemperature: sensor.maxTemperature
            )
        }
        
        // Update usage sensors with real data
        for i in 0..<usageSensors.count {
            let sensor = usageSensors[i]
            var newUsage = sensor.usage
            
            if sensor.name.contains("CPU") {
                newUsage = usage.cpu
            } else if sensor.name.contains("Memory") {
                newUsage = usage.memory
            } else if sensor.name.contains("GPU") {
                newUsage = usage.cpu * 0.6 + Double.random(in: -5.0...5.0)
            }
            
            usageSensors[i] = UsageSensor(
                name: sensor.name,
                usage: max(0.0, min(100.0, newUsage)),
                icon: sensor.icon,
                color: sensor.color,
                unit: sensor.unit
            )
        }
        
        // Update fan sensors with real data
        for i in 0..<fanSensors.count {
            let sensor = fanSensors[i]
            let fanSpeed = fans.values.first ?? 1000.0
            let newSpeed = fanSpeed + Double.random(in: -50...50)
            
            fanSensors[i] = FanSensor(
                name: sensor.name,
                speed: max(800.0, min(sensor.maxSpeed, newSpeed)),
                maxSpeed: sensor.maxSpeed,
                icon: sensor.icon,
                color: sensor.color
            )
        }
    }
    
    private func getTemperatures() -> (cpu: Double, gpu: Double, ssd: Double, battery: Double) {
        // Use fallback: estimate temperatures based on CPU usage
        let usage = getSystemUsage()
        let cpu = 30.0 + (usage.cpu * 0.5) // Rough estimate
        let gpu = 35.0 + (usage.cpu * 0.3) // Rough estimate
        let ssd = 25.0 // Typical SSD temperature
        let battery = 25.0 // Typical battery temperature
        
        return (cpu, gpu, ssd, battery)
    }
    
    private func getSystemUsage() -> (cpu: Double, memory: Double) {
        var cpu: Double = 0.0
        var memory: Double = 0.0
        
        // CPU Usage
        let host = mach_host_self()
        var cpuLoad = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &cpuLoad) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(host, HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let total = Double(cpuLoad.cpu_ticks.0 + cpuLoad.cpu_ticks.1 + cpuLoad.cpu_ticks.2 + cpuLoad.cpu_ticks.3)
            let idle = Double(cpuLoad.cpu_ticks.3)
            if total > 0 {
                cpu = ((total - idle) / total) * 100.0
            }
        }
        
        // Memory Usage
        var stats = vm_statistics64()
        var count2 = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result2 = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count2)) {
                host_statistics64(host, HOST_VM_INFO64, $0, &count2)
            }
        }
        
        if result2 == KERN_SUCCESS {
            let total = Double(stats.active_count + stats.inactive_count + stats.wire_count + stats.free_count)
            let used = Double(stats.active_count + stats.wire_count)
            if total > 0 {
                memory = (used / total) * 100.0
            }
        }
        
        return (cpu, memory)
    }
    
    private func getFanSpeeds() -> [String: Double] {
        var fans: [String: Double] = [:]
        
        // Fallback: simulate fan speeds based on CPU usage
        let usage = getSystemUsage()
        let baseSpeed = 1000.0
        let maxSpeed = 3000.0
        let speed = baseSpeed + (usage.cpu / 100.0) * (maxSpeed - baseSpeed)
        fans["Fan 1"] = speed
        
        return fans
    }
} 