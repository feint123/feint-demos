

pub mod sort;

use std::usize;

use bevy::{prelude::*};
use sort::{BubbleSort, QuickSort};

const TIME_STEP: f32 = 1.0/60.0;
const SPEED:f32 = 50.0;
const SQUARE_WIDTH:f32 = 10.;
const DIVIDER_WIDTH:f32 = 5.;
const SQUARE_SCALE:f32 = 10.;
const BORDER_X:f32 = 10000.;
const MAX_SQUARE_HEIGHT:f32 = 400.;
const COLORS:[Color; 3] = [Color::RED, Color::GREEN, Color::BLUE];
fn main() {
    App::new()
        .add_plugins(DefaultPlugins) // 默认插件
        .add_startup_system(setup) // 初始化配置，添加游戏组件
        .add_system(move_square) // 添加控制方块移动的脚本
        .add_system(check_move_status) // 添加检查方块移动状态的脚本
        .add_system(update_square_destination) // 添加更新方块目标位置的脚本
        .add_system(highlight_moved_square) // 添加高亮移动的方块的脚本
        .insert_resource(ClearColor(Color::BLACK)) // 清空背景颜色为黑色
        .run();
}

fn setup(mut command: Commands) {
    let arrs = vec![12,32,3,43,40,12,4,64,5,33,10,4,25,3,34,27,10];
    // 添加摄像头
    command.spawn(Camera2dBundle::default());
    // 初始化冒泡排序的控制器
    init_controller(&mut command, &arrs, &BubbleSort{}, Vec2::new(0., -200.), 1);
    // 初始化快速排序的控制器
    init_controller(&mut command, &arrs, &QuickSort{}, Vec2::new(-300.0, -200.), 2);
}

#[derive(Component, Clone)]
struct Square {
    destination: f32, // 方块的移动目标位置
    val: i32, // 方块所代表的数值
    square_id: usize, //方块id
    move_id: usize, // 方块所属的控制器id
}

#[derive(Component)]
struct MoveController {
    state: bool, // 移动状态
    current_step: usize, // 当前进行到的步骤
    steps: Vec<Square>, // 步骤列表
    move_id: usize, // 控制器id
}

/**
 * 交换两个方块，并添加到步骤列表中
 */
fn swap_square(data: &mut[Square], steps: &mut Vec<Square>, i:usize, j:usize) {
    steps.push(Square {
        destination: data[i].destination,
        val: data[j].val,
        square_id: data[j].square_id,
        move_id: data[j].move_id,
    });

    steps.push(Square {
        destination: data[j].destination,
        val: data[i].val,
        square_id: data[i].square_id,
        move_id: data[i].move_id,
    });
    // 交换 i，j 两个节点的目标位置
    let des = data[j].destination;
    data[j].destination = data[i].destination;
    data[i].destination = des;
    data.swap(i, j);
}

/**
 *  实现该trait 的struct 可以生成排序步骤
 */
trait SortStep {
    fn step(&self, data: &mut Vec<Square>) -> Vec<Square>;
}

/**
 * 初始化控制器
 *  
 */
fn init_controller(command: &mut Commands, data: &[i32], sort_step: &impl SortStep, offset: Vec2, move_id: usize) {
    
    let mut init_squares = Vec::new();
    // 根据待排序的数组初始化方块列表
    for (i, val) in data.iter().enumerate() {
        init_squares.push(Square {
            destination: offset.x + (SQUARE_WIDTH + DIVIDER_WIDTH) * i as f32,
            val: *val,
            square_id: i,
            move_id,
        });
    }
    // 生成方块的移动步骤
    let steps = sort_step.step(&mut init_squares.clone());
    // 添加MoveController组件
    command.spawn(MoveController {
        state: true,
        current_step: 0,
        steps,
        move_id,
    });
    // 遍历添加Square组件
    for (_i, square) in init_squares.iter().enumerate() {
        let mut square_height = (square.val as f32 * SQUARE_SCALE).clamp(0., MAX_SQUARE_HEIGHT);
        if square_height == MAX_SQUARE_HEIGHT {
            square_height += square.val as f32 - MAX_SQUARE_HEIGHT/SQUARE_SCALE;
        }
        command.spawn((
                SpriteBundle {
                    sprite: Sprite {
                        color: COLORS[move_id.clamp(0, COLORS.len() -1)],
                        ..default()
                    },
                    transform: Transform {
                        // 方块的初始目标位置为方块 x 轴的初始位置
                        translation: Vec3::new(square.destination, square_height/2. + offset.y, 0.),
                        scale: Vec3::new(SQUARE_WIDTH, square_height, 1.),
                        ..default()
                    },
                    ..default()
                },
                Square {
                    ..*square
                }));
    } 

}

/**
 * 执行方块移逻辑的system，根据【Square】进行过滤
 */
fn move_square(mut query: Query<(&mut Transform, &Square), With<Square>>) {
    for (mut square_transform, square) in &mut query {

        if square_transform.translation.x < square.destination {
            let new_position = square_transform.translation.x + SPEED * TIME_STEP;
            square_transform.translation.x = new_position.clamp(-BORDER_X, square.destination);
        } else {
            let new_position = square_transform.translation.x - SPEED * TIME_STEP;
            square_transform.translation.x = new_position.clamp(square.destination, BORDER_X);
        }
    }
}
/**
 * 高亮当前在移动的方块
 */
fn highlight_moved_square(mut query: Query<(&mut Sprite, &Transform, &Square), With<Square>>) {
    for (mut sprite, square_transform, square) in &mut query {
        if square.destination != square_transform.translation.x {
            sprite.color = Color::WHITE;
        } else {
            sprite.color = COLORS[square.move_id.clamp(0, COLORS.len())] 
        }
    }
}
/**
 *  校验方块当前的移动状态
 */
fn check_move_status(query: Query<(&Transform, &Square), With<Square>>,
                     mut ctrl_query: Query<&mut MoveController, With<MoveController>>) {
    for mut move_controller in &mut ctrl_query {
        let mut move_finished = true;

        for (square_transform, square) in &query {
            if square.move_id == move_controller.move_id && square_transform.translation.x != square.destination {
                move_finished = false;
            }
        }

        move_controller.state = move_finished;
    }
}


/**
 * 更新方块的目标位置
 *
 */
fn update_square_destination(mut query: Query<(&Transform, &mut Square), With<Square>>,
                             mut ctrl_query: Query<&mut MoveController, With<MoveController>>) {
    for mut move_controller in &mut ctrl_query {
        if move_controller.state && move_controller.current_step < move_controller.steps.len() {
            move_controller.state = false;

            for (_, mut square) in &mut query {
                if square.square_id == move_controller.steps[move_controller.current_step].square_id
                    && square.move_id == move_controller.move_id {
                        square.destination = move_controller.steps[move_controller.current_step].destination;
                    }
            }

            move_controller.current_step +=1;
        }
    }
}
