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
