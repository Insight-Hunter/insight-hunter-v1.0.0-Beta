import React from 'react'
export default function AppHeader({ right }: { right?: React.ReactNode }){
  return (<div className='appbar'><div className='appbar-inner'>
    <div className='h-stack'><img src='/logo-insight-hunter.svg' alt='Insight Hunter' style={{height:28}}/></div>
    <div className='h-stack'>{right}</div>
  </div></div>)
}
