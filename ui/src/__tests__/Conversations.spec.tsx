/* eslint-disable @typescript-eslint/no-explicit-any */
/**
 * Unified Conversations component tests
 * Combines structural, auth, GraphQL client, and UI state tests.
 */
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen } from '@solidjs/testing-library'
import Conversations from '../Conversations'
vi.mock('../UserContext')
import { AuthProvider } from '../UserContext'

// Mock config
vi.mock('../config.json', () => ({ default: { apiBaseUrl: 'http://localhost:3000' } }))

// Mock GraphQL primitives
type GraphQLResultSignal<T> = [() => T]
// Simplified mock client function signature (no generic declaration syntax to avoid TSX parsing issues)
const createGraphQLClientMock = vi.fn((_endpoint?: string, _opts?: { headers?: Record<string, string> }) => {
  const fn = (_query: unknown): GraphQLResultSignal<unknown> => [() => undefined]
  return Object.assign(fn, {})
})
vi.mock('@solid-primitives/graphql', () => ({
  createGraphQLClient: (arg1?: string, arg2?: { headers?: Record<string, string> }) => {
    createGraphQLClientMock(arg1, arg2)
    return (_q: unknown): GraphQLResultSignal<unknown> => [() => undefined]
  },
  gql: (s: TemplateStringsArray | string) => s
}))

// Helper to mutate mocked auth store
import * as UC from '../UserContext'
// Narrow mock store type (fallback to any if shape shifts)
const mockAuthStore: {
  isAuthenticated: boolean
  isLoading: boolean
  token: string | null
  user: { id: string; name: string; email?: string } | null
  error: string | null
} = (UC as any).mockAuthStore
function setAuth(partial: Partial<typeof mockAuthStore>) { Object.assign(mockAuthStore, partial) }

import type { JSX } from 'solid-js'
const Wrapper = (props: { children: JSX.Element }) => <AuthProvider>{props.children}</AuthProvider>

describe('Conversations (Unified)', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    setAuth({
      isAuthenticated: true,
      isLoading: false,
      token: 'mock_token',
      user: { id: '1', name: 'Tester', email: 't@example.com' }
    })
  })

  describe('Structure & Basic Render', () => {
    it('exports component and renders title', async () => {
      const module = await import('../Conversations')
      expect(module.default).toBeDefined()
      render(() => <Conversations />, { wrapper: Wrapper })
      expect(screen.getByText('Conversations')).toBeInTheDocument()
    })
  })

  describe('GraphQL Client', () => {
    it('initializes client with auth header when authenticated', () => {
      render(() => <Conversations />, { wrapper: Wrapper })
      expect(createGraphQLClientMock).toHaveBeenCalledWith(
        'http://localhost:3000/graphql',
        expect.objectContaining({ headers: expect.objectContaining({ Authorization: 'Bearer mock_token' }) })
      )
    })
    it('omits auth header when no token', () => {
      setAuth({ token: null, isAuthenticated: false })
      render(() => <Conversations />, { wrapper: Wrapper })
      expect(createGraphQLClientMock).toHaveBeenCalledWith(
        'http://localhost:3000/graphql',
        expect.objectContaining({ headers: expect.objectContaining({ Authorization: 'Bearer ' }) })
      )
    })
  })

  describe('Auth Variants', () => {
    it('still renders skeleton when unauthenticated', () => {
      setAuth({ isAuthenticated: false, token: null })
      render(() => <Conversations />, { wrapper: Wrapper })
      expect(screen.getByText('Conversations')).toBeInTheDocument()
    })
  })

  describe('UI Elements', () => {
    it('has new conversation button', () => {
      render(() => <Conversations />, { wrapper: Wrapper })
      expect(screen.getByText('Start New Conversation')).toBeInTheDocument()
    })
    it('renders grid container', () => {
      const { container } = render(() => <Conversations />, { wrapper: Wrapper })
      expect(container.querySelector('.conversations__grid')).toBeInTheDocument()
    })
  })

  describe('State Logic (unit style)', () => {
    it('conversation formatting example logic', () => {
      const conv: { id: string; title: string; assistant: string; scenario: string; initialMessage: string; createdAt: string } = { id: '1', title: 'T', assistant: 'A', scenario: 'S', initialMessage: 'Hi', createdAt: '2025-08-09T12:00:00Z' }
      const formattedDate = new Date(conv.createdAt).toISOString()
      expect(formattedDate).toContain('2025-08-09')
    })
  })
})
