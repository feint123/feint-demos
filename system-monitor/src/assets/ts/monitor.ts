

export class SysMonitorData {
    sensors!: any;
    load_avg!: number;
}

export class CpuData {
    chip_name!: string;
    physical_core_count!: number;
    global_usage!: number;
    cores!: CpuCoreData[];
}

export class CpuCoreData {
    usage!: number;
    frequency!: number;
}

export class ProcessData {
    memory!: number;
    name!: string;
    pid!: string;
}

export class SensorData {
    label!: string;
    temperature!: number;
}

export class BatteryData {
    
    // 电池温度
    temperature!: string;
    // 循环周期
    cycle_count!: number;
    // 充电状态
    state!: number;
    // 电量百分比
    percentage!: number;
    // // 还需多久充满
    // time_to_full: u32,
    // // 电池剩余使用时间
    // time_to_empty: u32,
    // 电池健康
    state_of_health!: string;
}

export class MemoryData {
    total_memory!: number;
    total_swap!: number;
    used_memory!: number;
    used_swap!: number;
}