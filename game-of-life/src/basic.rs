// 定义游戏中会使用到的一些基础组件
use bevy::{prelude::{Resource, Color}, time::Timer};
use bevy::prelude::Component;
use rand::Rng;
// 控制游戏的状态
#[derive(Resource, Clone)]
pub struct GameState {
    pub paused: bool, // 游戏状态
    pub row_count: usize, // 整个细胞世界的宽度
    pub density: usize, // 1~9, 随机生产细胞初始分布的概率
    pub circles: i32, // 细胞存活周期数
    pub active_cells: Vec<bool>, // 细胞存活状态
}
// ui控件的相关状态
#[derive(Resource)]
pub struct UiState {
    pub row_count_input: f32,
    pub density_input: f32,
}

impl Default for UiState {
    fn default() -> Self {
        Self { row_count_input: 10. , density_input: 3. }
    }
}

// 计时器
#[derive(Resource)]
pub struct LifeTimer(pub Timer);

// 初始化游戏状态
impl GameState {
    pub fn new(density: usize, row_count: usize) -> Self { 
        let mut arr = Vec::new();
        let mut rng = rand::thread_rng();
        for _ in 0..row_count*row_count {
            if rng.gen_range(0..10) < density { 
                arr.push(true);
            } else {
                arr.push(false);
            }
        }
        Self { 
            paused: true,
            row_count,
            density,
            circles: 0,
            active_cells: arr, 
        }
    }

}

impl Default for GameState {
    fn default() -> Self {
        Self::new(3, 10)
    }
}


// 细胞ID
#[derive(Component)]
pub struct CellId(pub i32);
// 细胞集合
#[derive(Component)]
pub struct CellSet;

// 细胞激活时候的颜色
pub const ACTIVE_COLOR:Color = Color::rgb(106. / 255., 168. / 255., 79. / 255.);
// 细胞死亡时候的颜色
pub const INIT_COLOR: Color = Color::rgb(0.1, 0.1, 0.1);
// UI控件区域的高度
pub const UI_HEIGHT: f32 = 40.;
// 窗口初始化宽度
pub const WINDOW_INIT_WIDTH: f32 = 900.;
pub const WINDOW_INIT_HEIGHT: f32 = 700.;
