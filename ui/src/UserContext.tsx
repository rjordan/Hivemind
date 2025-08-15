import { createContext, createSignal, useContext, createEffect, JSX, on } from 'solid-js'
import { createStore } from 'solid-js/store'
import { getCurrentUser } from './hivemind_svc'
import type { User } from './types'

// User type moved to shared types

interface AuthStore {
  isLoading: boolean;
  error: string | null;
}

interface AuthActions {
  login: (token: string, user?: User) => Promise<void>;
  logout: () => void;
  getToken: () => string | null;
  getUser: () => User | null;
  isAuthenticated: () => boolean;
  refreshUser: () => Promise<void>;
}

type AuthContextType = [AuthStore, AuthActions];

const UserContext = createContext<AuthContextType>()

export function AuthProvider(props: { children: JSX.Element }) {
  const [store, setStore] = createStore<AuthStore>({
    isLoading: true,
    error: null,
  })

  const [authToken, setAuthToken] = createSignal<string | null>(localStorage.getItem('auth_token'))
  const [user, setUser] = createSignal<User | null>(null)

  const isAuthenticated = () => user() !== null

  const toErrorMessage = (err: unknown): string =>
    err instanceof Error ? err.message : typeof err === 'string' ? err : 'Unknown error'

  const refreshUserInternal = async (token: string | null) => {
    // No token: clear user and error, don't fetch
    if (!token) {
      setUser(null)
      setStore({ isLoading: false, error: null })
      return
    }

    setStore({ isLoading: true, error: null })
    try {
      const currentUser = await getCurrentUser(token)
      // Treat null/undefined as invalid token
      if (!currentUser) {
        localStorage.removeItem('auth_token')
        setAuthToken(null)
        setUser(null)
        setStore({ error: null })
        return
      }
      setUser(currentUser)
      setStore({ error: null })
    } catch (error) {
      console.error('Error fetching current user: ', error)
      const msg = toErrorMessage(error)
      // Optionally clear token on auth failure; keep it conservative for now
      setUser(null)
      setStore({ error: msg })
    } finally {
      setStore({ isLoading: false })
    }
  }

  // React when the token changes
  createEffect(
    on(
      authToken,
      (token) => {
        void refreshUserInternal(token)
      },
      { defer: false }
    )
  )

  const login = async (token: string) => {
    try {
      setStore({ error: null })
      // Store token and user info in localStorage
      localStorage.setItem('auth_token', token)
      setAuthToken(token)
      // Effect will pick this up; optionally force refresh immediately
      // void refreshUserInternal(token)
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Login failed'
      setStore({
        isLoading: false,
        error: errorMessage,
      })
      throw error
    }
  }

  const logout = () => {
    // Clear localStorage
    localStorage.removeItem('auth_token')
    setAuthToken(null)
    setUser(null)

    setStore({
      isLoading: false,
      error: null,
    })
  }

  const getToken = () => authToken()

  const getUser = () => user()

  const refreshUser = async () => {
    await refreshUserInternal(authToken())
  }

  const authActions: AuthActions = {
    login,
    logout,
    getToken,
    getUser,
    isAuthenticated,
    refreshUser,
  }

  return (
    <UserContext.Provider value={[store, authActions]}>
      {props.children}
    </UserContext.Provider>
  )
}

export function useAuth(): AuthContextType {
  const context = useContext(UserContext)
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

// Helper function to check if user is authenticated
export const isAuthenticated = (): boolean => {
  try {
    const context = useContext(UserContext)
    if (!context) return false
    const [, actions] = context
    return actions.isAuthenticated()
  } catch {
    return false
  }
}

export default UserContext
