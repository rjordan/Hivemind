/* eslint-disable @typescript-eslint/no-explicit-any */
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen } from '@solidjs/testing-library'
import Conversations from '../Conversations'
vi.mock('../UserContext')
import { AuthProvider } from '../UserContext'

// Mock config (used by service)
vi.mock('../config.json', () => ({ default: { apiBaseUrl: 'http://localhost:3000' } }))

// Mock service calls
const getConversationsMock = vi.fn(async (_token: string | null) => ({
  conversations: { edges: [], pageInfo: { hasNextPage: false, hasPreviousPage: false, startCursor: '', endCursor: '' } }
}))
vi.mock('../hivemind_svc', () => ({
  getConversations: (token: string | null) => getConversationsMock(token)
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

  describe('Service', () => {
    it('calls getConversations with token when authenticated', async () => {
      render(() => <Conversations />, { wrapper: Wrapper })
      // allow effect to run
      await new Promise((r) => setTimeout(r, 0))
      expect(getConversationsMock).toHaveBeenCalledWith('mock_token')
    })
    it('calls getConversations with null when no token', async () => {
      setAuth({ token: null, isAuthenticated: false })
      render(() => <Conversations />, { wrapper: Wrapper })
      await new Promise((r) => setTimeout(r, 0))
      expect(getConversationsMock).toHaveBeenCalledWith(null)
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
