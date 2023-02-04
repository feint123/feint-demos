import { EChartsType } from "echarts/core";

export const gaugeOption = {
    series: [
        {
            name: 'usage',
            type: 'gauge',
            radius: '95%',
            areaStyle: {},
            progress: {
                show: true,
                roundCap: true,
                width: 8,
            },
            itemStyle: {
                color: '#58D9F9',
                shadowColor: 'rgba(0,138,255,0.45)',
                shadowBlur: 10,
                shadowOffsetX: 2,
                shadowOffsetY: 2
            },
            axisLabel: {
                show: false,
            },
            axisPointer: {
                show: false,
            },
            axisTick: {
                show: false,
            },
            splitLine: {
                show: false,
            },
            axisLine: {
                lineStyle: {
                    width: 8,
                    color: [[1, '#666']]
                },
                roundCap: true,
            },
            anchor: {
                show: false,
            },
            pointer: {
                show: false,
            },
            detail: {
                valueAnimation: true,
                fontSize: 20,
                color: 'inherit',
                offsetCenter: ['0%', '0%'],
            },
            data: [{
                value: 0,
            }]
        },
    ]
};



export function setSpecialGuage(echart: EChartsType, name: string, value: any) {
    echart.setOption({
        series: [{
            data: [
                {
                    title: {
                        show: true,
                        fontSize: 10,
                        color: '#E5EAF3',
                        offsetCenter: ['0%', '60%'],
                    },
                    name: name,
                    value: value
                }
            ]
        }]
    })
}
