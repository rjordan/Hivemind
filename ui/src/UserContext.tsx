import { createContext, useContext, createEffect, JSX } from 'solid-js';
import { createStore } from 'solid-js/store';

// User and Auth types
interface User {
  id: string;
  name: string;
  email?: string;
  avatar_url?: string;
  github_username?: string;
}

interface AuthStore {
  isAuthenticated: boolean;
  isLoading: boolean;
  token: string | null;
  user: User | null;
  error: string | null;
}

interface AuthActions {
  login: (token: string, user?: User) => Promise<void>;
  logout: () => void;
  clearError: () => void;
}

type AuthContextType = [AuthStore, AuthActions];

const UserContext = createContext<AuthContextType>();

export function AuthProvider(props: { children: JSX.Element }) {
  const [store, setStore] = createStore<AuthStore>({
    isAuthenticated: false,
    isLoading: true,
    token: null,
    user: null,
    error: null,
  });

  // Initialize auth state from localStorage
  createEffect(() => {
    const token = localStorage.getItem('auth_token');
    const userInfo = localStorage.getItem('user_info');

    if (token) {
      let user = null;
      if (userInfo) {
        user = JSON.parse(userInfo);
      }

      setStore({
        isAuthenticated: true,
        token,
        user,
        isLoading: false,
        error: null,
      });
    } else {
      setStore({ isLoading: false });
    }
  });

  const login = async (token: string, user?: User) => {
    try {
      setStore({ isLoading: true, error: null });

      // Store token and user info in localStorage
      localStorage.setItem('auth_token', token);
      if (user) {
        localStorage.setItem('user_info', JSON.stringify(user));
      }

      setStore({
        isAuthenticated: true,
        token,
        user: user || null,
        isLoading: false,
        error: null,
      });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Login failed';
      setStore({
        isAuthenticated: false,
        token: null,
        user: null,
        isLoading: false,
        error: errorMessage,
      });
      throw error;
    }
  };

  const logout = () => {
    // Clear localStorage
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_info');

    setStore({
      isAuthenticated: false,
      isLoading: false,
      token: null,
      user: null,
      error: null,
    });
  };

  const clearError = () => {
    setStore({ error: null });
  };

  const authActions: AuthActions = {
    login,
    logout,
    clearError,
  };

  return (
    <UserContext.Provider value={[store, authActions]}>
      {props.children}
    </UserContext.Provider>
  );
}

export function useAuth(): AuthContextType {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

// Helper function to check if user is authenticated
export const isAuthenticated = (): boolean => {
  try {
    const context = useContext(UserContext);
    if (!context) return false;
    const [store] = context;
    return store.isAuthenticated;
  } catch {
    return false;
  }
};

export default UserContext;
