pub mod basic;

use basic::*;
use bevy::prelude::*;

use bevy_egui::{egui, EguiContext, EguiPlugin};

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugin(EguiPlugin)
        .insert_resource(LifeTimer(Timer::from_seconds(0.2, TimerMode::Repeating)))
        .init_resource::<GameState>()
        .init_resource::<UiState>()
        .add_startup_system(setup)
        .add_system(update_cells_status)
        .add_system(draw_cells)
        .add_system(handle_ui_events)
        .insert_resource(ClearColor(Color::BLACK))
        .run();

}


/**
 *  游戏初始化
 */
fn setup(mut commands: Commands, 
         game_state: ResMut<GameState>, mut windows: ResMut<Windows>) {
    let window = windows.get_primary_mut().unwrap();
    window.set_resolution(WINDOW_INIT_WIDTH, WINDOW_INIT_HEIGHT);
    commands.spawn(Camera2dBundle::default());
    setup_cells(commands, game_state, window); 
}

/**
 * 初始化细胞区域
 */
fn setup_cells(mut commands: Commands, 
         game_state: ResMut<GameState>, window: &Window) {
    commands.spawn((SpriteBundle {
        sprite: Sprite{
            color: Color::rgba(0.,0.,0.,0.),
            ..default()
        },
        ..default()
    }, CellSet))
    .with_children(|parent| {
        let padding = 40.;
        let height = window.height() - UI_HEIGHT;
        let total_width = if window.width() > height {
            height - padding
        } else {
            window.width() - padding
        }; 
        let width = total_width / game_state.row_count as f32;
        // 计算细胞整体的偏移量，使其居中
        let delta_x = -total_width/2. + width/2.;
        let delta_y = -total_width/2. + width/2. - UI_HEIGHT/2.;
        for i in 0..game_state.row_count as i32 {
            for j in 0..game_state.row_count as i32 {
                parent.spawn((SpriteBundle {
                    sprite: Sprite {
                        color: INIT_COLOR,
                        ..default()
                    },
                    transform: Transform { 
                        translation: Vec3::new(delta_x + width * j as f32, 
                                               delta_y + width * i as f32, 0.),
                                               scale: Vec3::new(width * 0.9, width * 0.9, 1.),
                                               ..default()
                    },
                    ..default()
                }, CellId(i * game_state.row_count as i32 + j)));
            }
        }
    });

}

 

/////////////--------systems--------////////////////

/**
 * 更新细胞的状态
 * 细胞过少：如果一个活细胞少于两个活的邻居，它就会死亡。
 * oxo    oxo
 * oxo -> ooo
 * ooo    ooo
 * 正常：一个有两个或三个活邻居的活细胞可以延续到下一代。
 * xxo    xxo
 * oxo -> oxo
 * ooo    ooo
 * 细胞过多，过度竞争：一个有超过三个活邻居的活细胞死亡。
 * xox    xox
 * oxo -> oxo
 * xoo    xoo
 * 繁衍：如果一个死细胞正好有三个活着的邻居，它就会复活。
 * xox    xox
 * ooo -> oxo
 * xoo    xoo
 */
fn update_cells_status(time: Res<Time>, mut timer: ResMut<LifeTimer>,
                       mut game_state: ResMut<GameState>) {
    if game_state.paused {
        return;
    }
    if timer.0.tick(time.delta()).just_finished() {
        let mut next_circle = Vec::new();
        let mut alives = 0;
        for (index, cell_status) in game_state.active_cells.iter().enumerate() {
            let rows = index / game_state.row_count;
            let colums = index % game_state.row_count;
            let mut arr = Vec::new();
            if rows >= 1 {
                arr.push(index - game_state.row_count);
                if colums >= 1{
                    arr.push(index -1);
                    arr.push(index - 1 - game_state.row_count);
                }
                if colums + 1 < game_state.row_count {
                    arr.push(index +1);
                    arr.push(index + 1 - game_state.row_count);
                }

            }
            if rows + 1 < game_state.row_count {
                arr.push(index + game_state.row_count);
                if colums >= 1{
                    arr.push(index - 1 + game_state.row_count);
                }
                if colums + 1 < game_state.row_count {
                    arr.push(index + 1 + game_state.row_count);
                }
            }
            let mut active_cells = 0;
            for i in arr.iter() {
                if game_state.active_cells[*i] {
                    active_cells += 1;
                }
            }

            if *cell_status {
                if active_cells <= 1 || active_cells >= 4{
                    next_circle.push(false);
                } else {
                    next_circle.push(true);
                    alives += 1;
                }
            } else if active_cells == 3 {
                next_circle.push(true);
                alives += 1;
            } else {
                next_circle.push(false);
            }
        }
        if alives == 0 {
            game_state.paused = true;
        }
        game_state.active_cells = next_circle;
        // 周期数+1
        game_state.circles += 1;

    }
}
/**
 * 绘制cell的颜色
 */
fn draw_cells(mut query: Query<(&CellId,&mut Sprite), With<CellId>>, game_state: Res<GameState>) {
    for (cellid, mut sprite) in &mut query {
        if game_state.active_cells[cellid.0 as usize] {
            sprite.color = ACTIVE_COLOR;
        } else {
            sprite.color = INIT_COLOR;
        }
    }
}


/**
 * 处理重置按钮 
 */
fn handle_reset_btn(game_state: &mut ResMut<GameState>, ui_state: ResMut<UiState>) {
    game_state.row_count = ui_state.row_count_input as usize;
    game_state.density = ui_state.density_input as usize;

    let new_state = GameState::new(game_state.density, game_state.row_count);
    game_state.active_cells = new_state.active_cells;
    game_state.circles = new_state.circles;
    game_state.paused = true;
}


/**
 * 处理游戏开始按钮
 */
fn handle_start_btn(game_state: &mut ResMut<GameState>) {
    game_state.paused = !game_state.paused;
}

/**
 * 处理ui相关的事件
 */
fn handle_ui_events(mut egui_context: ResMut<EguiContext>,
              mut game_state: ResMut<GameState>,
              mut ui_state: ResMut<UiState>,
              query: Query<Entity, With<CellSet>>,
              mut commands: Commands,
              mut windows: ResMut<Windows>) {
    let window = windows.get_primary_mut().unwrap();
    egui::TopBottomPanel::top("game_control_panel")
        .resizable(false)
        .min_height(UI_HEIGHT)
        .show(egui_context.ctx_mut(), |ui| {
            ui.with_layout(egui::Layout::centered_and_justified(egui::Direction::LeftToRight), |ui| {
                ui.horizontal(|ui| {
                    let circles = game_state.circles;
                    // 控制细胞区域的总行数 10 ～ 100
                    ui.label("rows: ");
                    ui.add(egui::Slider::new(&mut ui_state.row_count_input,10.0..=100.).step_by(10.));
                    // 控制初始化时随机生成细胞的密度 0 ～9
                    ui.label("density: ");
                    ui.add(egui::Slider::new(&mut ui_state.density_input,0.0..=9.).step_by(1.));
                    // 控制游戏开始和暂停
                    if game_state.paused {
                        if ui.button("Start").clicked() {
                            handle_start_btn(&mut game_state);
                        }
                    } else if ui.button("Pause").clicked() {
                        handle_start_btn(&mut game_state);
                    }
                    // 重置游戏状态
                    if ui.button("Reset").clicked() {
                        handle_reset_btn(&mut game_state, ui_state);
                        let entity = query.single();
                        commands.entity(entity).despawn_recursive();
                        setup_cells(commands, game_state, window);
                    }
                    ui.label(format!("circles: {}", circles));
                });
            });
        });
}
