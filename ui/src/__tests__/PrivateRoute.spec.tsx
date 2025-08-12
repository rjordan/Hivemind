/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * Comprehensive Tests for PrivateRoute Component
 *
 * Tests for route protection, rendering logic, and integration with UserContext.
 */

import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen } from '@solidjs/testing-library'
import { Component } from 'solid-js'
import PrivateRoute from '../PrivateRoute'
// Mock router Navigate only (unit tests shouldn't depend on router context)
vi.mock('@solidjs/router', () => ({
  Navigate: (props: { href: string }) => <div data-testid="redirect" data-href={props.href}>Redirect</div>,
}))
// Use the mocked UserContext (../__mocks__/UserContext.tsx)
vi.mock('../UserContext')
import * as UserContextModule from '../UserContext'
const { AuthProvider, mockAuthStore } = UserContextModule as unknown as { AuthProvider: (p: { children: import('solid-js').JSX.Element }) => import('solid-js').JSX.Element; mockAuthStore: any }

// Test components
const ProtectedContent: Component = function ProtectedContent() {
  return <div>Protected Content</div>
}

// Helper component used directly in each test
const RenderProtected = (child: import('solid-js').JSX.Element = <ProtectedContent />) => (
  <AuthProvider>
    <PrivateRoute>{child}</PrivateRoute>
  </AuthProvider>
)

// Helper to mutate mock store
function setAuth(partial: Partial<typeof mockAuthStore>) {
  Object.assign(mockAuthStore, partial)
}

describe('PrivateRoute Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('shows loading spinner when auth is loading', () => {
    setAuth({ isAuthenticated: false, isLoading: true, user: null, token: null })
    render(() => RenderProtected())
    expect(screen.getByText('Loading...')).toBeInTheDocument()
    expect(document.querySelector('.loading__spinner')).toBeInTheDocument()
    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument()
    expect(screen.queryByTestId('redirect')).not.toBeInTheDocument()
  })

  it('redirects when unauthenticated and not loading', () => {
    setAuth({ isAuthenticated: false, isLoading: false, user: null, token: null })
    render(() => RenderProtected())
    expect(screen.queryByText('Protected Content')).not.toBeInTheDocument()
    expect(screen.getByTestId('redirect')).toHaveAttribute('data-href', '/login')
  })

  it('renders children when authenticated', () => {
    setAuth({
      isAuthenticated: true,
      isLoading: false,
      user: { id: '1', email: 'test@example.com', name: 'Test User', avatar_url: 'https://example.com/avatar.jpg' },
      token: 'mock_token'
    })
    render(() => RenderProtected())
    expect(screen.getByText('Protected Content')).toBeInTheDocument()
    expect(screen.queryByTestId('redirect')).not.toBeInTheDocument()
  })

  it('does not show loading when authenticated', () => {
    setAuth({
      isAuthenticated: true,
      isLoading: false,
      user: { id: '1', email: 'test@example.com', name: 'Test User', avatar_url: 'https://example.com/avatar.jpg' },
      token: 'mock_token'
    })
    render(() => RenderProtected())
    expect(screen.queryByText('Loading...')).not.toBeInTheDocument()
  })

  it('renders arbitrary JSX child when authenticated', () => {
    setAuth({
      isAuthenticated: true,
      isLoading: false,
      user: { id: '1', email: 'test@example.com', name: 'Test User', avatar_url: 'https://example.com/avatar.jpg' },
      token: 'mock_token'
    })

    const TestChild = () => <div data-testid="test-child">Test Child</div>
    render(() => RenderProtected(<TestChild />))
    expect(screen.getByTestId('test-child')).toBeInTheDocument()
  })
})
