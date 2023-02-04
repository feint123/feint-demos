
const barWidth = 16;

export const memoryOption = {
    dataset: {
        source:[['memory', 0, 16]]
    },
    grid: {
        left: 8,
        right: 8,
        bottom: 0,
        top: 0,
        containLabel: true
    },
    xAxis: {
        max: 18,
        splitLine: {
            show: false,
        },
        axisLabel: {
            show: true,
        },
        axisLine: { show: false },
        axisTick: { show: false },
        interval: 4,
    },
    yAxis: {
        data: ['memory'],
        splitLine: {
            show: false
        },
        axisLabel: {
            show: false,
        },
        axisLine: { show: false },
        axisTick: { show: false }
    },
    series: [
        {
            label: {
                show: true,
                formatter: '{@[1]}GB'
            },
            name: 'fill',
            type: 'bar',
            barWidth: barWidth,
            itemStyle: {
                
                borderRadius: 2,
            },
            encode:{
                x: 1,
                y: 0
            },
            z: 5,
        },

        {
            name: 'empty',
            type: 'bar',
            barWidth: barWidth,
            stack: 'total',
            barGap: '-100%',
            itemStyle: {
                opacity:.3,
                color: '#999',
                borderRadius: [2,0,0,2],
            },
            encode:{
                x: 2,
                y: 0
            },
        },

        {
            name: 'swap',
            type: 'bar',
            barWidth: barWidth,
            stack: 'total',
            barGap: '-100%',
            itemStyle: {
                color: '#e6b600',
                opacity:1,
                borderRadius: [0,2,2,0],
            },
            encode:{
                x: 3,
                y: 0
            },
        },
    ]
};