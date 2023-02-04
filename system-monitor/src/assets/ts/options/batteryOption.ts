import * as echarts from "echarts";

const fillLinear = new echarts.graphic.LinearGradient(0, 0, 1, 0, [
    { offset: 0, color: '#0a915daa' },
    { offset: 1, color: '#0a915d' },
], false)

const barWidth = 16;

export const batteryOption = {
    dataset: {
        source:[['battery',0, 100]]
    },
    grid: {
        left: 13,
        right: 13,
        bottom: 0,
        top: 0,
        containLabel: true
    },
    xAxis: [{
        splitLine: {
            show: false,
        },
        axisLabel: {
            show: false,
        },
        axisLine: { show: false },
        axisTick: { show: false }
    }],
    yAxis: {
        data: ['battery'],
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
            name: 'fill',
            type: 'bar',
            barWidth: barWidth,
            itemStyle: {
                color: fillLinear,
                borderRadius: 4,
            },
            encode:{
                x: 1,
                y: 0
            },
        },

        {
            name: 'fill',
            type: 'bar',
            barWidth: barWidth,
            barGap: '-100%',
            itemStyle: {
                color: 'none',
                borderColor: '#fff',
                borderRadius: 4,
            },
            encode:{
                x: 2,
                y: 0
            },
            z: 5,
        },
        {
            type: 'pictorialBar',
            symbol: 'roundRect',
            symbolSize: [ 2, barWidth/2],
            symbolOffset: [4, 0],
            symbolPosition: "end",
            itemStyle: {
                color: '#fff',
            },
            data: [100],
            z: 10,
        },
    ]
};