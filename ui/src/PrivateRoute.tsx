import { Component, JSX, Show } from 'solid-js'
import { Navigate } from '@solidjs/router'
import { useAuth } from './UserContext'

type PrivateRouteProps = {
  children: JSX.Element;
};

/**
 * PrivateRoute
 * Handles three states:
 * 1. Loading auth -> show spinner
 * 2. Authenticated -> render children
 * 3. Unauthenticated -> redirect to /login
 */
export const PrivateRoute: Component<PrivateRouteProps> = (props) => {
  const [store] = useAuth()

  return (
    <Show
      when={!store.isLoading}
      fallback={
        <div class="loading">
          <div class="loading__spinner" />
          Loading...
        </div>
      }
    >
      <Show when={store.isAuthenticated} fallback={<Navigate href="/login" />}>
        {props.children}
      </Show>
    </Show>
  )
}

export default PrivateRoute
