import { Component } from 'solid-js'
import { Router, Route } from '@solidjs/router'
import { PrivateRoute } from './PrivateRoute'

import Home from './Home'
import Conversations from './Converstations'
import Login from './Login'
import AuthCallback from './AuthCallback'

export const Routes: Component = () => {
  return (
    <Router>
      <Route path="/login" component={Login} />
      <Route path="/auth/callback" component={AuthCallback} />
      <Route path="/" component={Home} />
      // Private routes
      <Route path="/conversations" component={() => <PrivateRoute><Conversations /></PrivateRoute>} />
    </Router>
  )
}

export default Routes
