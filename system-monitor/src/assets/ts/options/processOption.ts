import { CallbackDataParams } from "echarts/types/dist/shared";

export const processOption = {
    dataset: {
        source:[]
    },
    grid: {
        left: 0,
        right: 50,
        bottom: 0,
        top: 0,
        containLabel: true
    },
    xAxis: {
        min: 0,
        splitLine: {
            show: false,
        },
        axisLabel: {
            show: false,
            align: 'right',
        },
        axisLine: { show: false },
        axisTick: { show: false },
        type: 'value',
    },
    yAxis: {
        splitLine: {
            show: false
        },
        axisLabel: {
            show: false,
        },
        axisLine: { show: false },
        axisTick: { show: false },
        type: 'category',
    },
    series: [
        {
            label: {
                show: true,
                formatter: '{@[1]}',
                position: 'insideLeft',
                color: '#E5EAF3',
                opacity: 1,
            },
            name: 'fill',
            type: 'bar',
            // barWidth: barWidth,
            itemStyle: {
                opacity: .2,
                borderRadius: 4,
            },
            showBackground: true,
            backgroundStyle: {
                borderRadius: 4,
            },
            encode:{
                x: 2,
                y: 0
            },
            z: 5,
        },

        {
            label: {
                show: true,
                formatter: function(param:CallbackDataParams) {
                    const memory = (<any[]>param.value)[2];
                    if (memory>1024) {
                        return `${(memory/1024).toFixed(2)}GB`
                    } else {
                        return `${memory}MB`
                    }
                },
                position: 'right',
                opacity: 1,
                color: '#E5EAF3'
    
            },
            name: 'fill',
            type: 'pictorialBar',
            symbol: 'rect',
            symbolRepeat: 'fixed',
            itemStyle: {
                opacity: 0,
            },
            encode:{
                x: 2,
                y: 0
            },
            z: 5,
        },
    ]
};