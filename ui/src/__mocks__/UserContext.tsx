import { createContext } from 'solid-js';
import { vi } from 'vitest';

// Mock implementation of the auth store
const mockAuthStore = {
  isAuthenticated: false,
  isLoading: false,
  token: null,
  user: null,
  error: null,
};

// Mock implementation of the auth actions
const mockAuthActions = {
  login: vi.fn(),
  logout: vi.fn(),
  clearError: vi.fn(),
};

// Create a UserContext with the mock store and actions
const UserContext = createContext<[typeof mockAuthStore, typeof mockAuthActions]>([mockAuthStore, mockAuthActions]);

// Custom hook to use the auth context
export const useAuth = () => [mockAuthStore, mockAuthActions] as const;

// Minimal AuthProvider used in tests
export const AuthProvider = (props: { children: any }) => {
  return (
    <UserContext.Provider value={[mockAuthStore, mockAuthActions]}>
      {props.children}
    </UserContext.Provider>
  );
};

export const isAuthenticated = () => mockAuthStore.isAuthenticated;

// Export mockAuthStore and mockAuthActions for direct manipulation in tests
export { mockAuthStore, mockAuthActions };

export default UserContext;
