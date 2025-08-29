import React, { useMemo } from 'react'
import Button from '../components/Button'
type Point = { month: string; cashIn: number; cashOut: number; netCash: number; eomBalance: number }
const data: Point[] = [
  { month: 'Sep', cashIn: 28000, cashOut: 21000, netCash: 7000,  eomBalance: 42000 },
  { month: 'Oct', cashIn: 29500, cashOut: 21900, netCash: 7600,  eomBalance: 49600 },
  { month: 'Nov', cashIn: 30000, cashOut: 23500, netCash: 6500,  eomBalance: 56100 },
  { month: 'Dec', cashIn: 31800, cashOut: 24900, netCash: 6900,  eomBalance: 63000 },
]
export default function Forecast() {
  const totals = useMemo(() => {
    const cashIn = data.reduce((s,d)=>s+d.cashIn,0)
    const cashOut = data.reduce((s,d)=>s+d.cashOut,0)
    const net = cashIn - cashOut
    return { cashIn, cashOut, net }
  }, [])
  return (<div className='v-stack'>
    <h1 className='hero-title'>Cashflow Forecast</h1>
    <p className='hero-sub'>Rolling 90 days · <span className='tag'>Updated 2m ago</span></p>
    <div className='controls'><select className='select' defaultValue='90'><option value='30'>Last 30 days</option><option value='90'>Last 90 days</option><option value='180'>Last 6 months</option></select>
      <select className='select' defaultValue='base'><option value='base'>Base case</option><option value='best'>Best case</option><option value='worst'>Worst case</option></select>
      <Button className='btn-accent'>Run forecast</Button>
    </div>
    <div className='stat-grid'>
      <div className='stat'><div className='kpi'>${(totals.cashIn/1000).toFixed(1)}k</div><div className='kpi-label'>Cash In</div><Sparkline values={data.map(d=>d.cashIn)} stroke='var(--chart-teal)'/></div>
      <div className='stat'><div className='kpi'>${(totals.cashOut/1000).toFixed(1)}k</div><div className='kpi-label'>Cash Out</div><Sparkline values={data.map(d=>d.cashOut)} stroke='#94a3b8'/></div>
      <div className='stat'><div className='kpi'>${(totals.net/1000).toFixed(1)}k</div><div className='kpi-label'>Net Cash</div><Sparkline values={data.map(d=>d.netCash)} stroke='var(--chart-blue)'/></div>
    </div>
    <div className='card v-stack'><div className='h3 heading'>Forecast Overview</div><Chart data={data}/></div>
    <div className='card v-stack'><div className='h3 heading'>Insights</div><ul className='bullets'><li>Net cash remains positive; strongest month <strong>Dec</strong> at +$6.9k.</li><li>Vendor payouts cluster mid-month; smoothing improves EOM balance.</li><li>Receivables turn improving; keep AR cycle under 25 days.</li></ul></div>
    <div className='action-row'><Button className='btn-accent btn-lg'>⬇️ Export CSV</Button><Button className='btn-accent btn-lg'>✉️ Share Link</Button></div>
    <div className='section-title'>Upcoming Cash Events</div>
    <ul className='list'><li className='list-item'><div className='left'><span className='title'>Stripe Payout</span><span className='sub'>Oct 15 · Receivable</span></div><span className='amount-pos'>+$7,800</span></li>
      <li className='list-item'><div className='left'><span className='title'>Payroll</span><span className='sub'>Oct 31 · Fixed</span></div><span className='amount-neg'>-$5,200</span></li>
      <li className='list-item'><div className='left'><span className='title'>AWS / SaaS</span><span className='sub'>Nov 1 · Variable</span></div><span className='amount-neg'>-$1,140</span></li></ul>
  </div>)
}
function Sparkline({ values, stroke='black' }:{ values:number[]; stroke?:string }) {
  const max = Math.max(...values), min = Math.min(...values)
  const pts = values.map((v,i)=>{ const x = 8 + (i*(60/(values.length-1||1))); const y = 32 - ((v-min)/(max-min||1))*24; return `${x},${y}` }).join(' ')
  return (<svg viewBox='0 0 70 34' width='100%' height='38' style={{marginTop:6}}><polyline points={pts} fill='none' stroke={stroke} strokeWidth='2' strokeLinecap='round'/></svg>)
}
function Chart({ data }:{data:Point[]}) {
  const w=320, h=160, pad=28; const max = Math.max(...data.map(d=>Math.max(d.cashIn,d.cashOut, d.eomBalance))); const xStep = (w - pad*2) / (data.length)
  return (<svg viewBox={`0 0 ${w} ${h}`} width='100%' height='auto'><rect x='0' y='0' width={w} height={h} rx='12' fill='#fff'/>
    {data.map((d,i)=>{ const x = pad + i*xStep + 10; const inH  = (d.cashIn/max) * (h-70); const outH = (d.cashOut/max) * (h-70);
      return (<g key={d.month}><rect x={x-16} y={h-40-inH} width='12' height={inH} rx='4' fill='var(--chart-teal)'/>
        <rect x={x+4} y={h-40-outH} width='12' height={outH} rx='4' fill='#94a3b8'/>
        <text x={x-8} y={h-16} fontSize='10' fill='var(--muted-2)'>{d.month}</text></g>) })}
    <polyline points={data.map((d,i)=>{ const x = pad + i*xStep + 10; const y = (h-40) - (d.eomBalance/max)*(h-70); return `${x},${y}` }).join(' ')}
      fill='none' stroke='var(--chart-blue)' strokeWidth='2.5' strokeLinecap='round'/></svg>)
}
