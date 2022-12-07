use crate::{SortStep, swap_square, Square};



/**
 * 冒泡排序可视化
 *
 */
pub struct BubbleSort;

impl SortStep for BubbleSort {
    fn step(&self, data: &mut Vec<crate::Square>) -> Vec<crate::Square> {
        let mut steps = Vec::new();
        for i in 0..data.len() {
            for j in 0..data.len() - i -1 {
                if data[j].val > data[j+1].val {
                    swap_square(data, &mut steps, j+1, j);
                }
            }
        }
        steps
    }
}


/**
 * 快速排序可视化
 *
 */
pub struct QuickSort;

impl SortStep for QuickSort {
    fn step(&self, data: &mut Vec<Square>) -> Vec<Square> {
        let mut steps = Vec::new();
        QuickSort::quick_sort_part(data, &mut steps, 0, data.len());
        steps
    }
}

impl QuickSort {
    fn quick_sort_part(data: &mut Vec<Square>, steps: &mut Vec<Square>, start: usize, end:usize) {
        if end > start {
            let mid = Self::partition(data, steps, start, end);
            Self::quick_sort_part(data, steps, start, mid);
            Self::quick_sort_part(data, steps, mid + 1, end);
        }
    }

    fn partition(data: &mut[Square], steps: &mut Vec<Square>, start: usize, end:usize) -> usize {
        let p = data[start].val;
        let mut j = end;

        for i in (start+1..end).rev() {
            if data[i].val > p {
                j -= 1;
                swap_square(data, steps, i, j);
            }
        }
        
        swap_square(data, steps, start, j-1);
        j-1
    }
}
