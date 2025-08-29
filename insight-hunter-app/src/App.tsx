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
