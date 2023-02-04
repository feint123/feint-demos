import { CpuCoreData } from "../monitor";

const normalSpliteLine = {
    show: true,
    lineStyle: {
        color: '#4C4D4F',
        opacity: .5,
    }
};

export const cpuOption = {
    grid: {
        left: '4',
        right: '4',
        bottom: '4',
        top: '4',
        containLabel: true
    },
    xAxis: [{
        type: 'time',
        splitLine: normalSpliteLine,
        axisLabel: {
            show: false,
        },
        axisPointer: {
            show: false,
        },
        axisTick: {
            show: false,
        }
    }],
    yAxis: {
        type: 'value',
        min: 0,
        max: 100,
        splitLine: normalSpliteLine,
        axisLabel: {
            show: false,
        },
        axisTick: {
            show: false,
        },
        axisPointer: {
            value: 0,
            snap: true,
            show: false,
            label: {
                formatter: function (params: any): string {
                    return params.value.toFixed(0) + '%';
                }
            },
            handle: {
                show: true,
            }
        }
    },
    series: [
        {
            name: 'usage',
            type: 'line',
            areaStyle: {},
            showSymbol: false,
            markLine: {
                symbol: 'none',
                label: {
                    formatter: function (params: any): string {
                        return params.value.toFixed(0) + '%';
                    },
                    position: 'insideEndBottom',
                    color: '#E5EAF3'
                },
                data: [
                    {
                        type: 'max',
                    }
                ]
            }
        },
    ]
};


export function getCpuUsageDatas(cores: CpuCoreData[]): number[] {
    const line = [new Date().getTime(), new Date().getTime()];
    for (var i = 0; i < cores.length; i++) {
        line.push(cores[i].usage);
    }
    return line;
}