import React, { useMemo } from 'react'
import Button from '../components/Button'
type Point = { month: string; revenue: number; expense: number }
const series: Point[] = [
  { month: 'Sep', revenue: 32000, expense: 21000 },
  { month: 'Oct', revenue: 33500, expense: 21900 },
  { month: 'Nov', revenue: 34000, expense: 23500 },
  { month: 'Dec', revenue: 35800, expense: 24900 },
]
export default function Dashboard() {
  const totals = useMemo(() => {
    const rev = series.reduce((s,d)=>s+d.revenue,0)
    const exp = series.reduce((s,d)=>s+d.expense,0)
    const mrr = 6400, workspaces = 41, margin = Math.round(((rev-exp)/rev)*100)
    return { rev, exp, net: rev-exp, mrr, workspaces, margin }
  }, [])
  return (<div className='v-stack'>
    <h1 className='hero-title' style={{textAlign:'left'}}>Overview</h1>
    <div className='filters'><span className='filter active'>Last 90 days</span><span className='filter'>Last 6 months</span><span className='filter'>YTD</span></div>
    <div className='kpi-grid'>
      <div className='kpi-card'><div className='kpi-label'>MRR</div><div className='kpi-value'>${(totals.mrr/1000).toFixed(1)}k</div><div className='kpi-trend kpi-up'>+4.2% this month</div><MiniSpark values={series.map(s=>s.revenue)} stroke='var(--chart-teal)'/></div>
      <div className='kpi-card'><div className='kpi-label'>Active Workspaces</div><div className='kpi-value'>{totals.workspaces}</div><div className='kpi-trend kpi-up'>+3 new</div><MiniSpark values={[30,31,35,41]} stroke='var(--chart-blue)'/></div>
      <div className='kpi-card'><div className='kpi-label'>Net Cash</div><div className='kpi-value'>${(totals.net/1000).toFixed(1)}k</div><div className='kpi-trend kpi-up'>Positive</div><MiniSpark values={series.map(s=>s.revenue - s.expense)} stroke='#22c55e'/></div>
      <div className='kpi-card'><div className='kpi-label'>Profit Margin</div><div className='kpi-value'>{totals.margin}%</div><div className='kpi-trend kpi-down'>-2% vs last qtr</div><MiniSpark values={[24,23,19,17]} stroke='#ef4444'/></div>
    </div>
    <div className='card v-stack'><div className='h3 heading'>Revenue vs Expenses</div><BarsAndLine data={series}/><div className='action-row'><Button className='btn-accent'>Generate Report</Button><Button variant='outline'>View Details</Button></div></div>
    <div className='card v-stack'><div className='h3 heading'>Recent Activity</div>
      <ul className='activity'>
        <li><div className='left'><span className='title'>Report generated</span><span className='sub'>2m ago · P&L (Aug)</span></div><span className='kpi-trend kpi-up'>Ready</span></li>
        <li><div className='left'><span className='title'>Stripe payout</span><span className='sub'>Today · Receivable</span></div><span className='kpi-trend kpi-up'>+$7,800</span></li>
        <li><div className='left'><span className='title'>Marketing spend</span><span className='sub'>Yesterday · Expense</span></div><span className='kpi-trend kpi-down'>-$1,140</span></li>
      </ul>
    </div>
  </div>)
}
function MiniSpark({ values, stroke='black' }:{ values:number[]; stroke?:string }) {
  const max = Math.max(...values), min = Math.min(...values)
  const pts = values.map((v,i)=>{ const x = 6 + (i*(60/(values.length-1||1))); const y = 30 - ((v-min)/(max-min||1))*22; return `${x},${y}` }).join(' ')
  return (<svg viewBox='0 0 70 32' width='100%' height='36' style={{marginTop:6}}><polyline points={pts} fill='none' stroke={stroke} strokeWidth='2' strokeLinecap='round'/></svg>)
}
function BarsAndLine({ data }:{ data:Point[] }) {
  const w=320, h=160, pad=28; const max = Math.max(...data.map(d=>Math.max(d.revenue,d.expense))); const xStep = (w - pad*2) / (data.length); const netMax = Math.max(...data.map(p=>p.revenue-p.expense))
  return (<svg viewBox={`0 0 ${w} ${h}`} width='100%' height='auto'><rect x='0' y='0' width={w} height={h} rx='12' fill='#fff'/>
    {data.map((d,i)=>{ const x = pad + i*xStep + 10; const inH  = (d.revenue/max) * (h-70); const outH = (d.expense/max) * (h-70);
      return (<g key={d.month}><rect x={x-16} y={h-40-inH}  width='12' height={inH}  rx='4' fill='var(--chart-teal)'/>
        <rect x={x+4}  y={h-40-outH} width='12' height={outH} rx='4' fill='#94a3b8'/>
        <text x={x-8} y={h-16} fontSize='10' fill='var(--muted-2)'>{d.month}</text></g>)
    })}
    <polyline points={data.map((d,i)=>{ const x = pad + i*xStep + 10; const net = d.revenue - d.expense; const y = (h-40) - (net/netMax)*(h-70); return `${x},${y}` }).join(' ')}
      fill='none' stroke='var(--chart-blue)' strokeWidth='2.5' strokeLinecap='round'/></svg>)
}
