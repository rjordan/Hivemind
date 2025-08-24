/* eslint-disable @typescript-eslint/no-explicit-any */
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen } from '@solidjs/testing-library'
import Characters from '../Characters'
vi.mock('../UserContext')
import { AuthProvider } from '../UserContext'

// Mock config used by service
vi.mock('../config.json', () => ({ default: { apiBaseUrl: 'http://localhost:3000' } }))

// Mock service calls
const getCharactersMock = vi.fn(async (_token: string | null) => ({
  characters: {
    edges: [
      { node: { id: '1', name: 'Neo', alternateNames: ['The One'], tags: ['hero'], facts: [], createdAt: '', updatedAt: '' } },
      { node: { id: '2', name: 'Trinity', alternateNames: [], tags: ['ally'], facts: [], createdAt: '', updatedAt: '' } },
    ],
    pageInfo: { hasNextPage: false, hasPreviousPage: false, startCursor: '', endCursor: '' }
  }
}))
vi.mock('../hivemind_svc', () => ({
  getCharacters: (token: string | null) => getCharactersMock(token)
}))

import * as UC from '../UserContext'
const mockAuthStore: any = (UC as any).mockAuthStore
function setAuth(partial: Partial<typeof mockAuthStore>) { Object.assign(mockAuthStore, partial) }

import type { JSX } from 'solid-js'
const Wrapper = (props: { children: JSX.Element }) => <AuthProvider>{props.children}</AuthProvider>

describe('Characters Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
    setAuth({ isAuthenticated: true, isLoading: false, token: 'mock_token', user: { id: 'u', name: 'Test' } })
  })

  it('renders title and calls service with token', async () => {
    render(() => <Characters />, { wrapper: Wrapper })
    await new Promise((r) => setTimeout(r, 0))
    expect(screen.getByText('Characters')).toBeInTheDocument()
    expect(getCharactersMock).toHaveBeenCalledWith('mock_token')
  })

  it('shows grid with character cards', async () => {
    const { container } = render(() => <Characters />, { wrapper: Wrapper })
    await new Promise((r) => setTimeout(r, 0))
    expect(container.querySelector('.characters__grid')).toBeInTheDocument()
    expect(screen.getByText('Neo')).toBeInTheDocument()
    expect(screen.getByText('Trinity')).toBeInTheDocument()
  })

  it('passes null token when unauthenticated', async () => {
    setAuth({ token: null, isAuthenticated: false })
    render(() => <Characters />, { wrapper: Wrapper })
    await new Promise((r) => setTimeout(r, 0))
    expect(getCharactersMock).toHaveBeenCalledWith(null)
  })
})
