//
//  ContentView.swift
//  ThermalGuard
//
//  Created by Владимир Пушков on 15.07.2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var systemMonitor = SystemMonitor(isPreview: true)
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab: MonitoringTab = .all
    
    enum MonitoringTab: String, CaseIterable {
        case all = "All"
        case cpu = "CPU"
        case gpu = "GPU"
        case memory = "Memory"
        case storage = "Storage"
        case fans = "Fans"
        case battery = "Battery"
        
        var icon: String {
            switch self {
            case .all: return "gauge"
            case .cpu: return "cpu"
            case .gpu: return "display"
            case .memory: return "memorychip"
            case .storage: return "internaldrive"
            case .fans: return "fan"
            case .battery: return "battery.100"
            }
        }
        
        var color: Color {
            switch self {
            case .all: return .blue
            case .cpu: return .blue
            case .gpu: return .purple
            case .memory: return .green
            case .storage: return .orange
            case .fans: return .cyan
            case .battery: return .red
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    sidebarView
                        .frame(width: 180)
                        .background(Color(NSColor.windowBackgroundColor))
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        headerView
                        Divider()
                        ScrollView {
                            Group {
                                switch selectedTab {
                                case .all:
                                    AllSensorsView(systemMonitor: systemMonitor)
                                case .cpu:
                                    CPUSensorsView(systemMonitor: systemMonitor)
                                case .gpu:
                                    GPUSensorsView(systemMonitor: systemMonitor)
                                case .memory:
                                    MemorySensorsView(systemMonitor: systemMonitor)
                                case .fans:
                                    FansSensorsView(systemMonitor: systemMonitor)
                                case .battery:
                                    BatterySensorsView(systemMonitor: systemMonitor)
                                case .storage:
                                    // Пока нет отдельного представления для storage, можно показать заглушку
                                    Text("Storage sensors coming soon...")
                                        .font(.title2)
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                }
                            }
                            .padding(.horizontal, 32)
                            .padding(.top, 24)
                            .padding(.bottom, 220) // чтобы не перекрывало нижней панелью
                            .frame(maxWidth: .infinity, alignment: .top)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Нижняя панель всегда внизу
                bottomPanelsView
                    .frame(height: 220)
                    .background(Color(NSColor.controlBackgroundColor))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(NSColor.separatorColor)),
                        alignment: .top
                    )
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            // App Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "thermometer")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("ThermalGuard")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.top, 24)
                
                // Status indicator
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Live Monitoring")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 24)
            
            // Navigation Tabs
            VStack(spacing: 4) {
                ForEach(MonitoringTab.allCases, id: \.self) { tab in
                    NavigationTabButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { selectedTab = tab }
                    )
                }
            }
            
            Spacer()
            
            // Bottom controls
            VStack(spacing: 12) {
                Button(action: {
                    systemMonitor.startMonitoring()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .trailing
        )
    }
    
    private var headerView: some View {
        HStack {
            Text(selectedTab.rawValue)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            // Summary info
            if selectedTab == .all {
                HStack(spacing: 20) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int((systemMonitor.cpuTemperature + systemMonitor.gpuTemperature + systemMonitor.ssdTemperature) / 3))°C")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("CPU")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(systemMonitor.cpuTemperature))°C")
                            .font(.headline)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
    
    private var contentBodyView: some View {
        VStack(spacing: 24) {
            switch selectedTab {
            case .all:
                AllSensorsView(systemMonitor: systemMonitor)
            case .cpu:
                CPUSensorsView(systemMonitor: systemMonitor)
            case .gpu:
                GPUSensorsView(systemMonitor: systemMonitor)
            case .memory:
                MemorySensorsView(systemMonitor: systemMonitor)
            case .storage:
                StorageSensorsView(systemMonitor: systemMonitor)
            case .fans:
                FansSensorsView(systemMonitor: systemMonitor)
            case .battery:
                BatterySensorsView(systemMonitor: systemMonitor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
        .padding(.top, 24)
    }
    
    private var bottomPanelsView: some View {
        HStack(alignment: .top, spacing: 0) {
            fansPanelView
            separatorView
            diagnosticsPanelView
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 0)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .top
        )
    }
    
    private var fansPanelView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "fan")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.cyan)
                Text("Fans")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            if !systemMonitor.fanSensors.isEmpty {
                ForEach(systemMonitor.fanSensors, id: \.name) { sensor in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(sensor.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("\(Int(sensor.speed)) RPM")
                                .font(.system(size: 16, weight: .medium))
                            
                            Spacer()
                            
                            Text("Max: \(Int(sensor.maxSpeed)) RPM")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Fan control buttons
                        HStack(spacing: 12) {
                            Button("Auto") {
                                // TODO: Implement fan control
                            }
                            .buttonStyle(ModernButtonStyle(size: .small))
                            
                            Button("Max") {
                                // TODO: Implement fan control
                            }
                            .buttonStyle(ModernButtonStyle(size: .small))
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                }
            } else {
                Text("No fan sensors detected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var separatorView: some View {
        Rectangle()
            .frame(width: 1)
            .foregroundColor(Color(NSColor.separatorColor))
    }
    
    private var diagnosticsPanelView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.orange)
                Text("Diagnostics")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                DiagnosticRow(
                    title: "System Health",
                    status: "Good",
                    color: .green
                )
                
                DiagnosticRow(
                    title: "Temperature Sensors",
                    status: "Active",
                    color: .green
                )
                
                DiagnosticRow(
                    title: "Fan Sensors",
                    status: systemMonitor.fanSensors.isEmpty ? "Not Available" : "Active",
                    color: systemMonitor.fanSensors.isEmpty ? .orange : .green
                )
                
                DiagnosticRow(
                    title: "Battery Health",
                    status: "Good",
                    color: .green
                )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Navigation Tab Button
struct NavigationTabButton: View {
    let tab: ContentView.MonitoringTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : tab.color)
                    .frame(width: 20)
                
                Text(tab.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? tab.color : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 12)
    }
}

// MARK: - Helper Functions
private func colorFromString(_ colorString: String) -> Color {
    switch colorString.lowercased() {
    case "blue": return .blue
    case "purple": return .purple
    case "green": return .green
    case "orange": return .orange
    case "red": return .red
    case "cyan": return .cyan
    case "yellow": return .yellow
    case "gray", "grey": return .gray
    default: return .blue
    }
}

// MARK: - Sensor Views
struct AllSensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            // Temperature Sensors
            if !systemMonitor.temperatureSensors.isEmpty {
                SensorSection(title: "Temperatures") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(systemMonitor.temperatureSensors, id: \.name) { sensor in
                            ModernTemperatureRow(
                                name: sensor.name,
                                temperature: sensor.temperature,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // System Performance
            if !systemMonitor.usageSensors.isEmpty {
                SensorSection(title: "System Performance") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(systemMonitor.usageSensors, id: \.name) { sensor in
                            ModernUsageRow(
                                name: sensor.name,
                                usage: sensor.usage,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color),
                                unit: sensor.unit
                            )
                        }
                    }
                }
            }
            
            // Fan Speeds
            if !systemMonitor.fanSensors.isEmpty {
                SensorSection(title: "Fan Speeds") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(systemMonitor.fanSensors, id: \.name) { sensor in
                            ModernFanRow(
                                name: sensor.name,
                                speed: sensor.speed,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // Fallback if no data
            if systemMonitor.temperatureSensors.isEmpty && systemMonitor.usageSensors.isEmpty && systemMonitor.fanSensors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "thermometer")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No sensor data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Please check your system permissions and try refreshing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct CPUSensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            // CPU Temperature Sensors
            let cpuSensors = systemMonitor.temperatureSensors.filter { $0.name.contains("Core") || $0.name.contains("CPU") }
            if !cpuSensors.isEmpty {
                SensorSection(title: "CPU Temperature") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(cpuSensors, id: \.name) { sensor in
                            ModernTemperatureRow(
                                name: sensor.name,
                                temperature: sensor.temperature,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // CPU Performance
            let cpuUsageSensors = systemMonitor.usageSensors.filter { $0.name.contains("CPU") }
            if !cpuUsageSensors.isEmpty {
                SensorSection(title: "CPU Performance") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(cpuUsageSensors, id: \.name) { sensor in
                            ModernUsageRow(
                                name: sensor.name,
                                usage: sensor.usage,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color),
                                unit: sensor.unit
                            )
                        }
                    }
                }
            }
            
            // Fallback if no CPU data
            if cpuSensors.isEmpty && cpuUsageSensors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "cpu")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No CPU sensor data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct GPUSensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            // GPU Temperature Sensors
            let gpuSensors = systemMonitor.temperatureSensors.filter { $0.name.contains("GPU") }
            if !gpuSensors.isEmpty {
                SensorSection(title: "GPU Temperature") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(gpuSensors, id: \.name) { sensor in
                            ModernTemperatureRow(
                                name: sensor.name,
                                temperature: sensor.temperature,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // GPU Performance
            let gpuUsageSensors = systemMonitor.usageSensors.filter { $0.name.contains("GPU") }
            if !gpuUsageSensors.isEmpty {
                SensorSection(title: "GPU Performance") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(gpuUsageSensors, id: \.name) { sensor in
                            ModernUsageRow(
                                name: sensor.name,
                                usage: sensor.usage,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color),
                                unit: sensor.unit
                            )
                        }
                    }
                }
            }
            
            // Fallback if no GPU data
            if gpuSensors.isEmpty && gpuUsageSensors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "display")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No GPU sensor data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct MemorySensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            // Memory Temperature Sensors
            let memorySensors = systemMonitor.temperatureSensors.filter { $0.name.contains("Memory") }
            if !memorySensors.isEmpty {
                SensorSection(title: "Memory Temperature") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(memorySensors, id: \.name) { sensor in
                            ModernTemperatureRow(
                                name: sensor.name,
                                temperature: sensor.temperature,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // Memory Usage
            let memoryUsageSensors = systemMonitor.usageSensors.filter { $0.name.contains("Memory") }
            if !memoryUsageSensors.isEmpty {
                SensorSection(title: "Memory Usage") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(memoryUsageSensors, id: \.name) { sensor in
                            ModernUsageRow(
                                name: sensor.name,
                                usage: sensor.usage,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color),
                                unit: sensor.unit
                            )
                        }
                    }
                }
            }
            
            // Fallback if no memory data
            if memorySensors.isEmpty && memoryUsageSensors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "memorychip")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No memory sensor data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct StorageSensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            // Storage Temperature Sensors
            let storageSensors = systemMonitor.temperatureSensors.filter { $0.name.contains("SSD") || $0.name.contains("Storage") }
            if !storageSensors.isEmpty {
                SensorSection(title: "Storage Temperature") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(storageSensors, id: \.name) { sensor in
                            ModernTemperatureRow(
                                name: sensor.name,
                                temperature: sensor.temperature,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // Fallback if no storage data
            if storageSensors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "internaldrive")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No storage sensor data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct FansSensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            if !systemMonitor.fanSensors.isEmpty {
                SensorSection(title: "Fan Speeds") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(systemMonitor.fanSensors, id: \.name) { sensor in
                            ModernFanRow(
                                name: sensor.name,
                                speed: sensor.speed,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            } else {
                Text("No fan sensors detected")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
}

struct BatterySensorsView: View {
    let systemMonitor: SystemMonitor
    
    var body: some View {
        VStack(spacing: 24) {
            // Battery Temperature Sensors
            let batterySensors = systemMonitor.temperatureSensors.filter { $0.name.contains("Battery") }
            if !batterySensors.isEmpty {
                SensorSection(title: "Battery Temperature") {
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                        ForEach(batterySensors, id: \.name) { sensor in
                            ModernTemperatureRow(
                                name: sensor.name,
                                temperature: sensor.temperature,
                                icon: sensor.icon,
                                color: colorFromString(sensor.color)
                            )
                        }
                    }
                }
            }
            
            // Fallback if no battery data
            if batterySensors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "battery.100")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No battery sensor data available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Modern Sensor Components
struct SensorSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            content
        }
    }
}

struct ModernTemperatureRow: View {
    let name: String
    let temperature: Double
    let icon: String
    let color: Color
    
    private var temperatureColor: Color {
        if temperature > 80 { return .red }
        if temperature > 70 { return .orange }
        if temperature > 60 { return .yellow }
        return .green
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(Int(temperature))°C")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(temperatureColor)
            
            // Temperature bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(temperatureColor)
                        .frame(width: geometry.size.width * min(temperature / 100, 1), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 120, height: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

struct ModernUsageRow: View {
    let name: String
    let usage: Double
    let icon: String
    let color: Color
    let unit: String
    
    private var usageColor: Color {
        if usage > 90 { return .red }
        if usage > 80 { return .orange }
        if usage > 70 { return .yellow }
        return .green
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(Int(usage))\(unit)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(usageColor)
            
            // Usage bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(usageColor)
                        .frame(width: geometry.size.width * (usage / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 120, height: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

struct ModernFanRow: View {
    let name: String
    let speed: Double
    let icon: String
    let color: Color
    
    private var speedColor: Color {
        if speed > 4000 { return .red }
        if speed > 3000 { return .orange }
        if speed > 2000 { return .yellow }
        return .green
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(Int(speed)) RPM")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(speedColor)
            
            // Speed bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(speedColor)
                        .frame(width: geometry.size.width * min(speed / 5000, 1), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(width: 120, height: 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }
}

// MARK: - Diagnostic Components
struct DiagnosticRow: View {
    let title: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Button Styles
struct ModernButtonStyle: ButtonStyle {
    enum Size {
        case small, medium, large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium:
                return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .large:
                return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 11
            case .medium: return 13
            case .large: return 15
            }
        }
    }
    
    let size: Size
    
    init(size: Size = .medium) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size.fontSize, weight: .medium))
            .foregroundColor(configuration.isPressed ? .white : .primary)
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color.blue : Color(NSColor.controlBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .onAppear {
            // Use mock data for preview
            let _ = SystemMonitor(isPreview: true)
        }
}
