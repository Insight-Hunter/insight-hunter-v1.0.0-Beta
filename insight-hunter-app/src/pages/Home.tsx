import React, { useEffect, useRef } from 'react'
import Button from '../components/Button'
export default function Home(){
  useEffect(()=>{ const html=document.documentElement; const prev=html.getAttribute('data-theme')||'light'; html.setAttribute('data-theme','light'); return ()=>html.setAttribute('data-theme',prev) },[])
  const fileRef=useRef<HTMLInputElement>(null)
  return (<div className='v-stack'>
    <h1 className='hero-title'>AI-Powered Auto-CFO for<br/>Everyone</h1>
    <p className='hero-sub'>Enterprise-grade insights, now in your hands</p>
    <div className='cta-row' style={{marginTop:10}}>
      <Button className='btn-accent btn-lg' onClick={()=>fileRef.current?.click()}>Upload File (CSV)</Button>
      <Button className='btn-accent btn-lg' onClick={()=>alert('Connect QuickBooks flow')}>Connect QuickBooks</Button>
      <input ref={fileRef} type='file' accept='.csv' hidden onChange={e=>{ const f=e.target.files?.[0]; if(f) alert(`Selected: ${f.name}`)}} />
    </div>
    <div className='section-title'>AI Insights</div>
    <ul className='bullets'><li>Revenue up 12% QoQ, driven by new client acquisition</li><li>Marketing spend spiked 40% MoM — potential overbudget</li><li>Net profit margin down from 25% → 17% — dig into payroll</li></ul>
    <div className='grid-cards'>
      <div className='card image-card'><div className='card-title'>Revenue Trend</div>
        <svg viewBox='0 0 240 120' width='100%' height='100%'><rect x='0' y='0' width='240' height='120' rx='12' fill='#F0FDFA'/><polyline points='20,90 70,50 120,70 170,40 220,25' fill='none' stroke='var(--chart-teal)' strokeWidth='4' strokeLinecap='round'/>
        <circle cx='70' cy='50' r='5' fill='var(--chart-teal)'/><circle cx='120' cy='70' r='5' fill='var(--chart-teal)'/><circle cx='170' cy='40' r='5' fill='var(--chart-teal)'/><circle cx='220' cy='25' r='5' fill='var(--chart-teal)'/></svg>
      </div>
      <div className='card image-card'><div className='card-title'>Expense Breakdown</div>
        <svg viewBox='0 0 240 120' width='100%' height='100%'><rect x='0' y='0' width='240' height='120' rx='12' fill='#F0F9FF'/>
          <g transform='translate(120,60)'><path d='M0 0 L0 -40 A40 40 0 0 1 34.64 20 Z' fill='var(--chart-blue)'/>
            <path d='M0 0 L34.64 20 A40 40 0 0 1 -28.28 28.28 Z' fill='#38BDF8'/>
            <path d='M0 0 L-28.28 28.28 A40 40 0 1 1 0 -40 Z' fill='var(--chart-cyan)'/></g>
        </svg>
      </div>
    </div>
    <div className='action-row'><Button className='btn-accent btn-lg'>⬇️ Download Report</Button><Button className='btn-accent btn-lg' onClick={()=>alert('Email flow')}>✉️ Email to Client</Button></div>
    <div className='section-title'>Reports List</div><div className='pill-row'><div className='pill'>March 2025</div><div className='pill'>April 2025</div><div className='pill'>May 2025</div></div>
  </div>)
}
