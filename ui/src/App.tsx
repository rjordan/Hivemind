import './App.scss'

import { Component, Suspense } from 'solid-js'

import TopBar from './Topbar'
import { AuthProvider } from './UserContext'
import { Routes } from './Routes'

const App: Component = () => {
  return (
    <AuthProvider>
      <main class="min-h-screen bg-gray-100 hivemind-app">
        <TopBar />
        <Suspense fallback={<div>Loading...</div>}>
          <Routes />
        </Suspense>
      </main>
    </AuthProvider>
  )
}

export default App
