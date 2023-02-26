use std::collections::HashMap;

use battery::{Battery, Manager};
use sysinfo::{Component, ComponentExt, CpuExt, Disk, Process, ProcessExt, System, SystemExt};

#[derive(serde::Serialize, Default)]
pub struct SysMonitorData {
    host: HostData,
    disks: Vec<DiskData>,
    sensors: HashMap<String, f32>,
    load_avg: f64,
}

#[derive(serde::Serialize, Default)]
pub struct ProcessData {
    name: String,
    memory: f64,
    pid: String,
}

impl ProcessData {
    pub fn new(process: &Process) -> Self {
        Self {
            name: process.name().to_string(),
            memory: MemoryData::format_memory(process.memory()),
            pid: process.pid().to_string(),
        }
    }
}

#[derive(serde::Serialize, Default)]
pub struct SensorData {
    label: String,
    temperature: f32,
}

impl SensorData {
    pub fn new(component: &Component) -> Self {
        Self {
            label: component.label().to_string(),
            temperature: component.temperature(),
        }
    }
}

#[derive(serde::Serialize, Default)]
pub struct CpuData {
    // 芯片名称
    chip_name: String,
    // 物理核心数
    physical_core_count: usize,
    global_usage: f32,
    // cpu核心数据
    cores: Vec<CpuCoreData>,
}

impl CpuData {
    pub fn new(sysinfo: &System, cores: Vec<CpuCoreData>) -> Self {
        Self {
            chip_name: sysinfo.global_cpu_info().brand().to_string(),
            physical_core_count: sysinfo.physical_core_count().unwrap(),
            global_usage: sysinfo.global_cpu_info().cpu_usage(),
            cores,
        }
    }
}

/**
 * cpu 核心数据
 */
#[derive(serde::Serialize, Default)]
pub struct CpuCoreData {
    // cpu 使用率
    usage: f32,
    // 运行频率
    frequency: u64,
}

impl CpuCoreData {
    pub fn new(usage: f32, frequency: u64) -> Self {
        Self { usage, frequency }
    }
}

#[derive(serde::Serialize, Default)]
pub struct BatteryData {
    // 电池温度
    temperature: String,
    // 循环周期
    cycle_count: u32,
    // 充电状态
    state: i32,
    // 电量百分比
    percentage: f32,
    // // 还需多久充满
    // time_to_full: u32,
    // // 电池剩余使用时间
    // time_to_empty: u32,
    // 电池健康
    state_of_health: String,
}

/**
 * Battery { impl: MacOSDevice { source: PowerSource { io_object: IoObject(75011) } }, vendor: None, model: Some(\"bq20z451\"), serial_number: None, technology: Unknown, state: Full, capacity: 0.022820631, temperature: Some(302.08 K^1), percentage: 1.0, cycle_count: Some(24), energy: 4580.2803 m^2 kg^1 s^-2, energy_full: 4580.2803 m^2 kg^1 s^-2, energy_full_design: 200707.88 m^2 kg^1 s^-2, energy_rate: 0.0 m^2 kg^1 s^-3, voltage: 12.723001 m^2 kg^1 s^-3 A^-1, time_to_full: None, time_to_empty: None }", "temperature": "28.93℃" }
 */

impl BatteryData {
    pub fn new(battery: &Battery) -> Self {
        Self {
            temperature: format!("{:.2}℃", battery.temperature().unwrap().value - 273.15),
            cycle_count: battery.cycle_count().unwrap_or(0),
            state: match battery.state() {
                battery::State::Full => 1,
                battery::State::Charging => 2,
                battery::State::Discharging => 3,
                battery::State::Empty => 0,
                _ => -1,
            },
            percentage: battery.state_of_charge().value * 100.,
            state_of_health: format!("{:.2}%", battery.state_of_health().value * 100.),
        }
    }
}

#[derive(serde::Serialize, Default)]
pub struct HostData {}

#[derive(serde::Serialize, Default)]
pub struct MemoryData {
    total_memory: f64,
    total_swap: f64,
    used_memory: f64,
    used_swap: f64,
}

impl MemoryData {
    pub fn new(sysinfo: &System) -> Self {
        Self {
            total_memory: MemoryData::format_memory(sysinfo.total_memory()),
            total_swap: MemoryData::format_memory(sysinfo.total_swap()),
            used_memory: MemoryData::format_memory(sysinfo.used_memory()),
            used_swap: MemoryData::format_memory(sysinfo.used_swap()),
        }
    }

    fn format_memory(bytes: u64) -> f64 {
        return bytes as f64 / (1024. * 1024. * 1024.);
    }
}

#[derive(serde::Serialize, Default)]
pub struct DiskData {
    name: String,
}

impl DiskData {
    pub fn new(disk: &Disk) -> Self {
        Self {
            name: format!("{:?}", disk),
        }
    }
}

#[tauri::command]
pub fn system_info() -> SysMonitorData {
    let mut sys = System::new_all();
    sys.refresh_components();

    let mut sensors = HashMap::new();
    for component in sys.components() {
        sensors.insert(component.label().to_string(), component.temperature());
    }
    return SysMonitorData {
        host: HostData::default(),
        disks: vec![],
        sensors,
        load_avg: sys.load_average().one,
    };
}

#[tauri::command]
pub fn memory_info() -> MemoryData {
    let mut sys = System::new_all();
    sys.refresh_memory();
    return MemoryData::new(&sys);
}

#[tauri::command]
pub fn cpu_info() -> CpuData {
    let mut sys = System::new_all();
    sys.refresh_cpu();
    let mut cpu_cores = vec![];
    let cpus = sys.cpus();
    for cpu in cpus.iter() {
        cpu_cores.push(CpuCoreData::new(cpu.cpu_usage(), cpu.frequency()));
    }
    let cpu = CpuData::new(&sys, cpu_cores);
    return cpu;
}

#[tauri::command]
pub fn process_info() -> Vec<ProcessData> {
    let mut sys = System::new_all();
    sys.refresh_processes();
    let mut processes = vec![];
    for (pid, process) in sys.processes() {
        processes.push(ProcessData::new(&process));
    }
    processes.sort_by(|a, b| b.memory.partial_cmp(&a.memory).unwrap());
    return processes;
}

#[tauri::command]
pub fn battery_info() -> BatteryData {
    let manager = Manager::new().unwrap();
    let mut batteries = vec![];
    for (_, battery) in manager.batteries().unwrap().enumerate() {
        batteries.push(BatteryData::new(&battery.unwrap()));
        break;
    }
    if batteries.len() == 0 {
        return BatteryData::default();
    } else {
        return batteries.pop().unwrap();
    }
}

#[cfg(target_os = "macos")]
#[tauri::command]
pub fn update_tray_title(app: tauri::AppHandle) -> bool {

    let mut sys = System::new_all();
    sys.refresh_cpu();
    sys.refresh_memory();
    app.tray_handle()
        .set_title(
            format!(
                "| cpu: {:.0}% | mem: {:.2}GB",
                sys.global_cpu_info().cpu_usage(),
                MemoryData::format_memory(sys.used_memory() + sys.used_swap())
            )
            .as_str(),
        )
        .unwrap();
    return true;
}

#[cfg(target_os = "windows")]
#[tauri::command]
pub fn update_tray_title() -> bool {
    // do nothing
    return true;
}