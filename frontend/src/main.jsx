import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'
import { Capacitor } from '@capacitor/core'
import { StatusBar, Style } from '@capacitor/status-bar'
import { SplashScreen } from '@capacitor/splash-screen'

// Initialize Capacitor plugins
if (Capacitor.isNativePlatform()) {
  // Set status bar style
  StatusBar.setStyle({ style: Style.Dark })
  StatusBar.setBackgroundColor({ color: '#1e293b' })
  
  // Hide splash screen after app is ready
  window.addEventListener('DOMContentLoaded', async () => {
    await SplashScreen.hide()
  })
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
