#!/usr/bin/env bash
set -euo pipefail

APPDIR="insight-hunter-app"
rm -rf "$APPDIR"
mkdir -p "$APPDIR"
cd "$APPDIR"

# --- helper to write files safely ---
w() { mkdir -p "$(dirname "$1")"; cat > "$1" <<'EOF'
$2
EOF
}

# package.json
cat > package.json <<'EOF'
{
  "name": "insight-hunter-demo",
  "version": "0.1.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview --port 5173",
    "deploy": "wrangler pages deploy dist --project-name=insight-hunter-demo",
    "pages:dev": "wrangler pages dev --compatibility-date=2024-11-12",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@hono/zod-validator": "0.7.2",
    "hono": "^4.9.4",
    "papaparse": "5.4.1",
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "react-router-dom": "^6.26.2",
    "recharts": "2.12.7",
    "zod": "3.25.3"
  },
  "devDependencies": {
    "@types/react": "18.3.5",
    "@types/react-dom": "18.3.0",
    "@vitejs/plugin-react": "4.3.1",
    "typescript": "5.5.4",
    "vite": "^5.4.19",
    "wrangler": "4.32.0"
  },
  "engines": { "node": ">=18.17.0" }
}
EOF

# tsconfig.json
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020","DOM","DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "types": []
  },
  "include": ["src"]
}
EOF

# vite.config.ts
cat > vite.config.ts <<'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()] })
EOF

# index.html
cat > index.html <<'EOF'
<!doctype html>
<html lang="en" data-theme="light">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
    <meta name="theme-color" content="#f97316" />
    <link rel="preconnect" href="https://fonts.googleapis.com"/>
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap" rel="stylesheet"/>
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <title>Insight Hunter</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
EOF

# SPA redirects
mkdir -p public
cat > public/_redirects <<'EOF'
/*   /index.html   200
EOF

# favicon
cat > public/favicon.svg <<'EOF'
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 64 64'><rect width='64' height='64' rx='14' fill='#f97316'/><path d='M14 42c4-8 8-12 16-16v18' stroke='#fff' stroke-width='4' fill='none' stroke-linecap='round'/><circle cx='30' cy='30' r='4' fill='#fff'/></svg>
EOF

# logo
cat > public/logo-insight-hunter.svg <<'EOF'
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 180 34'><g transform='translate(0,3)'><circle cx='14' cy='14' r='12' stroke='#0F172A' stroke-width='3'/><path d='M6 18c2.3-4.2 4.6-6.3 8-8v10' stroke='#F97316' stroke-width='3' stroke-linecap='round'/><path d='M12 18h2M9 20h2M15 16h2' stroke='#0EA5E9' stroke-width='2' stroke-linecap='round'/><path d='M22 22l7 7' stroke='#0F172A' stroke-width='3' stroke-linecap='round'/></g><text x='42' y='24' font-family='Inter,Segoe UI,Arial,sans-serif' font-size='18' font-weight='800' fill='#0F172A' letter-spacing='1'>INSIGHT</text><text x='118' y='24' font-family='Inter,Segoe UI,Arial,sans-serif' font-size='18' font-weight='800' fill='#0F172A' letter-spacing='1'>HUNTER</text></svg>
EOF

# Cloudflare routes include for Functions
cat > _routes.json <<'EOF'
{
  "version": 1,
  "include": ["/api/*"]
}
EOF

# src bootstrap
mkdir -p src/styles src/components src/pages
cat > src/main.tsx <<'EOF'
import React from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './styles/tokens.css'
import './styles/base.css'
import './styles/components.css'

createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>
)
EOF

cat > src/App.tsx <<'EOF'
import React from 'react'
import { Routes, Route } from 'react-router-dom'
import Layout from './components/Layout'
import Home from './pages/Home'
import Dashboard from './pages/Dashboard'
import Forecast from './pages/Forecast'
import Settings from './pages/Settings'
import NotFound from './pages/NotFound'

export default function App(){
  return (
    <Routes>
      <Route element={<Layout/>}>
        <Route path='/' element={<Home/>}/>
        <Route path='/dashboard' element={<Dashboard/>}/>
        <Route path='/forecast' element={<Forecast/>}/>
        <Route path='/settings' element={<Settings/>}/>
        <Route path='*' element={<NotFound/>}/>
      </Route>
    </Routes>
  )
}
EOF

# CSS
cat > src/styles/tokens.css <<'EOF'
:root{
  --radius-sm:10px;--radius-md:14px;--radius-lg:16px;
  --shadow-1:0 1px 2px rgba(0,0,0,.04),0 6px 16px rgba(0,0,0,.06);
  --shadow-2:0 12px 30px rgba(0,0,0,.10);
  --accent-500:#f97316;--accent-600:#ea580c;--accent-700:#c2410c;
  --chart-teal:#06B6D4;--chart-blue:#0284C7;--chart-cyan:#67E8F9;
  --bg:#fff;--elev:#fff;--card:#fff;--text:#0f172a;
  --muted:#1f2937;--muted-2:#475569;--border:#e5e7eb;
}
[data-theme='light']{
  --bg:#fff;--elev:#fff;--card:#fff;--text:#0f172a;
  --muted:#1f2937;--muted-2:#475569;--border:#e5e7eb;
}
@media (prefers-color-scheme: dark){
  :root{
    --bg:#0f0f12;--elev:#15151a;--card:#1b1b22;
    --text:#f5f7ff;--muted:#c8cbda;--muted-2:#9aa2b2;--border:#252532;
  }
}
EOF

cat > src/styles/base.css <<'EOF'
*{box-sizing:border-box}
html,body,#root{height:100%}
html{-webkit-text-size-adjust:100%}
body{margin:0;font-family:Inter,ui-sans-serif,system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial;color:var(--text);background:var(--bg)}
img,svg,video,canvas{display:block;max-width:100%}
button{font:inherit}
.container{width:100%;max-width:560px;margin:0 auto;padding:16px}
.h-stack{display:flex;align-items:center;gap:12px}
.v-stack{display:flex;flex-direction:column;gap:12px}
.spread{display:flex;align-items:center;justify-content:space-between;gap:12px}
.heading{font-weight:700;letter-spacing:-.02em}
.h1{font-size:28px;line-height:1.1}.h2{font-size:22px;line-height:1.15}.h3{font-size:18px;line-height:1.2}
.text-muted{color:var(--muted)}.text-dim{color:var(--muted-2)}
@keyframes fadeSlideUp{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
.page{animation:fadeSlideUp .28s ease both}
@keyframes shimmer{0%{background-position:-468px 0}100%{background-position:468px 0}}
.skeleton{border-radius:12px;height:12px;width:100%;background:linear-gradient(90deg,rgba(0,0,0,.03) 0%,rgba(0,0,0,.07) 50%,rgba(0,0,0,.03) 100%);background-size:936px 100%;animation:shimmer 1.2s infinite linear}
.bullets{margin:0;padding-left:18px}
EOF

cat > src/styles/components.css <<'EOF'
.appbar{background:#fff;border-bottom:1px solid var(--border)}
.container{max-width:560px}
.btn{--btn-bg:var(--elev);--btn-fg:var(--text);--btn-br:16px;--btn-bd:var(--border);--btn-shadow:var(--shadow-1);appearance:none;border:1px solid var(--btn-bd);border-radius:var(--btn-br);background:var(--btn-bg);color:var(--btn-fg);padding:12px 16px;display:inline-flex;align-items:center;justify-content:center;gap:10px;text-decoration:none;cursor:pointer;box-shadow:var(--btn-shadow);transition:transform .06s,box-shadow .2s,background .2s,border-color .2s;position:relative;overflow:hidden}
.btn:active{transform:translateY(1px) scale(.99)}.btn:disabled{opacity:.6;cursor:not-allowed}
.btn-primary{--btn-bg:linear-gradient(135deg,var(--accent-500),var(--accent-700));--btn-bd:transparent;color:#fff}
.btn-outline{--btn-bg:transparent;--btn-bd:var(--accent-500);--btn-fg:var(--accent-700);background:#fff}
.btn-ghost{--btn-bg:transparent;--btn-bd:transparent;--btn-fg:var(--muted-2);box-shadow:none}
.btn-danger{--btn-bg:#ef4444;--btn-bd:transparent;color:#fff}
.btn-success{--btn-bg:#16a34a;--btn-bd:transparent;color:#fff}
.btn-accent{--btn-bg:var(--accent-500);--btn-bd:transparent;--btn-fg:#fff}
.btn-lg{padding:14px 18px;border-radius:16px;font-weight:600}.btn-sm{padding:8px 12px;border-radius:10px;font-size:14px}
.ripple{position:absolute;border-radius:999px;pointer-events:none;transform:translate(-50%,-50%);width:12px;height:12px;opacity:.4;background:white;mix-blend-mode:soft-light;animation:ripple .6s ease-out forwards}
@keyframes ripple{from{transform:translate(-50%,-50%) scale(1);opacity:.4}to{transform:translate(-50%,-50%) scale(35);opacity:0}}
.input,.select{width:100%;padding:12px 14px;border-radius:14px;border:1px solid var(--border);background:var(--elev);color:var(--text)}
.label{font-size:13px;color:var(--muted-2);margin-bottom:6px;display:block}
.chip{display:inline-flex;align-items:center;gap:8px;padding:8px 10px;border-radius:999px;background:#fff;border:1px solid var(--border)}
.appbar-inner{height:60px;display:flex;align-items:center;justify-content:space-between;padding:0 12px;max-width:560px;margin:0 auto}
.tabbar{position:sticky;bottom:0;z-index:10;backdrop-filter:blur(10px);background:#fff;border-top:1px solid var(--border)}
.tabbar-inner{height:64px;display:flex;align-items:center;justify-content:space-around;max-width:560px;margin:0 auto}
.tab-item{display:flex;flex-direction:column;align-items:center;gap:6px;font-size:11px;color:var(--muted-2);text-decoration:none}
.tab-item.active{color:var(--accent-600)}
.fab{position:fixed;right:16px;bottom:90px;z-index:12;border-radius:999px;width:56px;height:56px;display:grid;place-items:center;color:white;border:none;background:linear-gradient(135deg,var(--accent-500),var(--accent-700));box-shadow:var(--shadow-2)}
.grid-cards{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media (min-width:480px){.grid-cards{grid-template-columns:1fr 1fr}}
.hero-title{font-size:clamp(28px,6vw,36px);line-height:1.15;text-align:center;font-weight:800;letter-spacing:-.02em;color:var(--text)}
.hero-sub{text-align:center;color:var(--muted-2);margin-top:8px}
.cta-row{display:flex;gap:12px;justify-content:center;flex-wrap:wrap}.cta-row .btn{min-width:180px}
.section-title{font-size:22px;font-weight:800;color:var(--text);margin-top:16px}
.card.image-card{padding:14px}.card-title{font-weight:700;margin-bottom:10px;color:var(--text)}
.action-row{display:flex;gap:12px;flex-wrap:wrap}.action-row .btn{flex:1 1 200px}
.pill-row{display:flex;gap:12px;flex-wrap:wrap}.pill{padding:12px 16px;border-radius:12px;border:1px solid var(--border);background:#fff;color:var(--text)}
.settings-section{display:flex;flex-direction:column;gap:16px}
.form-grid{display:grid;grid-template-columns:1fr;gap:12px}
@media(min-width:520px){.form-grid{grid-template-columns:1fr 1fr}}
.field{display:flex;flex-direction:column;gap:6px}.help{color:var(--muted-2);font-size:12px}
.settings-card{background:#fff;border:1px solid var(--border);border-radius:16px;box-shadow:var(--shadow-1);padding:16px}
.code-inline{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,monospace;background:#fafafa;border:1px solid var(--border);border-radius:12px;padding:10px 12px;display:flex;align-items:center;justify-content:space-between;gap:10px;overflow:auto;white-space:nowrap}
.masked{filter:blur(5px)}.k-actions{display:flex;gap:8px;flex-wrap:wrap}
.radio-row{display:flex;gap:12px;flex-wrap:wrap}
.radio{display:inline-flex;align-items:center;gap:8px;padding:8px 12px;border:1px solid var(--border);border-radius:999px;background:#fff;cursor:pointer;user-select:none}
.radio input{appearance:none;width:14px;height:14px;border:2px solid var(--border);border-radius:999px;display:inline-block}
.radio input:checked{border-color:var(--accent-500);box-shadow:inset 0 0 0 3px #fff,0 0 0 2px var(--accent-500)}
.switch{position:relative;width:44px;height:26px}
.switch input{display:none}
.switch .track{position:absolute;inset:0;background:#e5e7eb;border:1px solid var(--border);border-radius:999px;transition:background .2s}
.switch .thumb{position:absolute;top:2px;left:2px;width:22px;height:22px;border-radius:999px;background:#fff;box-shadow:var(--shadow-1);transition:transform .2s}
.switch input:checked + .track{background:color-mix(in oklab,var(--accent-500) 85%,#fff)}
.switch input:checked ~ .thumb{transform:translateX(18px)}
.group-title{font-weight:800;color:var(--text);font-size:18px;margin-bottom:8px}
.danger{border-color:#fecaca;background:#fff5f5}
.controls{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media (min-width:420px){.controls{grid-template-columns:1fr 1fr auto}}
.stat-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px}
.stat{padding:14px;border:1px solid var(--border);border-radius:14px;background:#fff}
.kpi{font-size:22px;font-weight:800;color:var(--text)}
.kpi-label{color:var(--muted-2);font-size:12px;margin-top:4px}
.tag{display:inline-flex;align-items:center;gap:8px;padding:6px 10px;border:1px solid var(--border);border-radius:999px;background:#fff;color:var(--muted-2);font-size:12px}
.list{display:flex;flex-direction:column;gap:10px;margin:0;padding:0;list-style:none}
.list-item{display:flex;justify-content:space-between;align-items:center;gap:10px;padding:12px;border:1px solid var(--border);border-radius:12px;background:#fff}
.list-item .left{display:flex;flex-direction:column}
.list-item .title{font-weight:600;color:var(--text)}
.list-item .sub{color:var(--muted-2);font-size:12px}
.amount-pos{color:#16a34a;font-weight:700}.amount-neg{color:#dc2626;font-weight:700}
.kpi-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.kpi-card{background:#fff;border:1px solid var(--border);border-radius:16px;box-shadow:var(--shadow-1);padding:14px}
.kpi-label{color:var(--muted-2);font-size:12px}
.kpi-value{font-weight:800;font-size:22px;color:var(--text)}
.kpi-trend{font-size:12px;margin-top:4px}
.kpi-up{color:#16a34a}.kpi-down{color:#dc2626}
.filters{display:flex;gap:8px;flex-wrap:wrap}
.filter{padding:8px 12px;border:1px solid var(--border);border-radius:999px;background:#fff;font-size:12px;color:var(--muted-2)}
.filter.active{border-color:var(--accent-500);color:#111}
EOF

# Components
cat > src/components/Button.tsx <<'EOF'
import React, { ButtonHTMLAttributes, useRef } from 'react'
type Props = ButtonHTMLAttributes<HTMLButtonElement> & { variant?: 'primary'|'outline'|'ghost'|'danger'|'success'; size?: 'sm'|'md'|'lg'; loading?: boolean }
export default function Button({ variant='primary', size='md', loading=false, children, className='', onClick, ...rest }: Props) {
  const ref = useRef<HTMLButtonElement>(null)
  const handleClick: React.MouseEventHandler<HTMLButtonElement> = (e) => {
    const el = ref.current
    if (el) {
      const rect = el.getBoundingClientRect()
      const ripple = document.createElement('span'); ripple.className='ripple'
      ripple.style.left = `${e.clientX-rect.left}px`; ripple.style.top = `${e.clientY-rect.top}px`
      el.appendChild(ripple); setTimeout(() => ripple.remove(), 620)
    }
    onClick?.(e)
  }
  const v = variant ? `btn-${variant}` : ''
  const s = size === 'lg' ? 'btn-lg' : size === 'sm' ? 'btn-sm' : ''
  return (<button ref={ref} onClick={handleClick} className={['btn', v, s, className].join(' ')} {...rest}>
    {loading ? <span className='skeleton' style={{width:16,height:16,borderRadius:999}}/> : children}
  </button>)
}
EOF

cat > src/components/Icons.tsx <<'EOF'
import React from 'react'
export const ChartIcon = (p:any) => (<svg width='24' height='24' viewBox='0 0 24 24' fill='none' {...p}><path d='M4 19V5M10 19V9M16 19V3M22 19V13' stroke='currentColor' strokeWidth='1.5' strokeLinecap='round'/></svg>)
export const HomeIcon = (p:any) => (<svg width='24' height='24' viewBox='0 0 24 24' fill='none' {...p}><path d='M3 10.5L12 3l9 7.5V21a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1v-10.5z' stroke='currentColor' strokeWidth='1.5' strokeLinejoin='round'/></svg>)
export const CogIcon = (p:any) => (<svg width='24' height='24' viewBox='0 0 24 24' fill='none' {...p}><path d='M12 15.5a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z' stroke='currentColor' strokeWidth='1.5'/><path d='M19.4 15.5a7.97 7.97 0 0 0 .2-1.5 7.97 7.97 0 0 0-.2-1.5l2.1-1.6-2-3.5-2.5.8a8.21 8.21 0 0 0-2.6-1.5l-.4-2.6h-4l-.4 2.6a8.21 8.21 0 0 0-2.6 1.5l-2.5-.8-2 3.5 2.1 1.6a7.97 7.97 0 0 0-.2 1.5c0 .5.1 1 .2 1.5l-2.1 1.6 2 3.5 2.5-.8c.8.6 1.7 1.1 2.6 1.5l2.5.8 2-3.5-2.1-1.6z' stroke='currentColor' strokeWidth='1.2' strokeLinejoin='round'/></svg>)
export const MenuIcon = (p:any) => (<svg width='26' height='26' viewBox='0 0 24 24' fill='none' {...p}><path d='M4 7h16M4 12h16M4 17h16' stroke='currentColor' strokeWidth='2' strokeLinecap='round'/></svg>)
EOF

cat > src/components/TabBar.tsx <<'EOF'
import React from 'react'
import { NavLink } from 'react-router-dom'
import { HomeIcon, ChartIcon, CogIcon } from './Icons'
const TabItem = ({ to, icon, label }:{to:string, icon:React.ReactNode, label:string}) => (
  <NavLink to={to} className={({isActive}) => 'tab-item' + (isActive ? ' active' : '')}>
    {icon}<span>{label}</span>
  </NavLink>
)
export default function TabBar() {
  return (<div className='tabbar'><div className='tabbar-inner'>
    <TabItem to='/dashboard' icon={<HomeIcon/>} label='Home'/>
    <TabItem to='/forecast' icon={<ChartIcon/>} label='Forecast'/>
    <TabItem to='/settings' icon={<CogIcon/>} label='Settings'/>
  </div></div>)
}
EOF

cat > src/components/AppHeader.tsx <<'EOF'
import React from 'react'
export default function AppHeader({ right }: { right?: React.ReactNode }){
  return (<div className='appbar'><div className='appbar-inner'>
    <div className='h-stack'><img src='/logo-insight-hunter.svg' alt='Insight Hunter' style={{height:28}}/></div>
    <div className='h-stack'>{right}</div>
  </div></div>)
}
EOF

cat > src/components/Layout.tsx <<'EOF'
import React from 'react'
import { Outlet, useLocation } from 'react-router-dom'
import AppHeader from './AppHeader'
import TabBar from './TabBar'
export default function Layout(){
  const { pathname } = useLocation()
  const showTabs = pathname !== '/'
  return (
    <div style={{minHeight:'100dvh', display:'grid', gridTemplateRows:'auto 1fr auto'}}>
      <AppHeader />
      <main className='page' style={{ paddingBottom: showTabs ? 64 : 16 }}>
        <div className='container'><Outlet/></div>
      </main>
      {showTabs && <TabBar />}
    </div>
  )
}
EOF

# Pages
cat > src/pages/Home.tsx <<'EOF'
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
EOF

cat > src/pages/Forecast.tsx <<'EOF'
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
EOF

cat > src/pages/Dashboard.tsx <<'EOF'
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
EOF

cat > src/pages/NotFound.tsx <<'EOF'
import React from 'react'
export default function NotFound(){
  return (<div className='v-stack'><h1 className='hero-title'>Page not found</h1><p className='hero-sub'>The page you’re looking for doesn’t exist.</p></div>)
}
EOF

# Cloudflare Pages Functions API with validation
mkdir -p functions/api
cat > "functions/api/[[path]].ts" <<'EOF'
import { Hono } from 'hono'
import { z } from 'zod'
import { zValidator } from '@hono/zod-validator'

const app = new Hono().basePath('/api')

app.get('/health', (c) => c.json({ ok: true, service: 'insight-hunter' }))
app.get('/demo/summary', (c) => c.json([
  {label:'MRR', value:'$6,400'},
  {label:'Active Workspaces', value:'41'},
  {label:'Reports / wk', value:'183'}
]))
app.get('/demo/forecast', (c) => c.json([
  {month:'Sep',cashIn:28000,cashOut:21000,netCash:7000,eomBalance:42000},
  {month:'Oct',cashIn:29500,cashOut:21900,netCash:7600,eomBalance:49600}
]))

// Content-Type guard for JSON bodies
app.use('*', async (c, next) => {
  const m = c.req.method.toUpperCase()
  if (m === 'POST' || m === 'PUT' || m === 'PATCH') {
    const ct = c.req.header('content-type') || ''
    if (!ct.toLowerCase().includes('application/json')) {
      return c.json({ ok: false, error: 'Unsupported Media Type (expect application/json)' }, 415)
    }
  }
  await next()
})

const headerAuthSchema = z.object({ 'x-api-key': z.string().min(20) })
const reportCreateSchema = z.object({
  name: z.string().min(3).max(64),
  period: z.enum(['M','Q','Y']),
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  includeForecast: z.boolean().default(false),
}).strict()

app.post('/reports',
  zValidator('header', headerAuthSchema, (r, c) => { if (!r.success) return c.json({ ok:false, error:r.error.flatten() }, 401) }),
  zValidator('json', reportCreateSchema, (r, c) => { if (!r.success) return c.json({ ok:false, error:r.error.flatten() }, 400) }),
  async (c) => {
    const body = c.req.valid('json')
    return c.json({ ok:true, reportId: crypto.randomUUID(), input: body })
  }
)

app.onError((_err, c) => c.json({ ok:false, error:'Internal Server Error' }, 500))

export const onRequest = async (ctx: any) => {
  const url = new URL(ctx.request.url)
  if (!url.pathname.startsWith('/api')) {
    // let the static app handle non-API routes
    // @ts-ignore
    return ctx.next()
  }
  try {
    return await app.fetch(ctx.request, ctx.env, ctx.context)
  } catch {
    return new Response(JSON.stringify({ ok:false, error:'Unhandled exception' }), {
      status:500, headers:{'content-type':'application/json'}
    })
  }
}
EOF

echo "✅ Project scaffolded at $(pwd)"
echo "Next:"
echo "  1) npm i"
echo "  2) npm run dev   # open http://localhost:5173"
echo "  3) npm run build && npm run deploy  # Cloudflare Pages"
echo "To zip for upload: cd .. && zip -r insight-hunter-app.zip insight-hunter-app"
EOF
