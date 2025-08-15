import { Component } from 'solid-js'
import { Router, Route } from '@solidjs/router'
import { PrivateRoute } from './PrivateRoute'

import Home from './Home'
import Conversations from './Conversations'
import Login from './Login'
import AuthCallback from './AuthCallback'
import Characters from './Characters'

// Higher-order helper to wrap a component in auth guard
function protect<T>(Comp: Component<T>): Component<T> {
  return (props: T) => (
    <PrivateRoute>
      <Comp {...props} />
    </PrivateRoute>
  )
}

export const Routes: Component = () => (
  <Router>
    <Route path="/login" component={() => <Login />} />
    <Route path="/auth/callback" component={() => <AuthCallback />} />
    <Route path="/" component={() => <Home />} />
    {/* Protected routes */}
    <Route path="/conversations" component={protect(Conversations)} />
    <Route path="/characters" component={protect(Characters)} />
  </Router>
)

export default Routes
