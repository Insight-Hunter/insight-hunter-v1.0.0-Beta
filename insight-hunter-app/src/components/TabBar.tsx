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
