import { describe, it, expect, beforeEach, vi, afterAll } from 'vitest';
import { render, fireEvent, screen, waitFor } from '@solidjs/testing-library';
import Login from '../Login';

// Mock router navigate capturing spy (must not reference uninitialized variable)
const navigateSpy = vi.fn();
vi.mock('@solidjs/router', () => ({ useNavigate: () => navigateSpy }));

// Spy for login action
const loginSpy = vi.fn();
vi.mock('../UserContext', () => ({
  useAuth: () => [{}, { login: loginSpy }],
  AuthProvider: (p: any) => p.children,
}));

// Mock config
vi.mock('../config.json', () => ({ default: { apiBaseUrl: 'http://localhost:3000' } }));

// Mock env
const mockEnv: any = { VITE_GITHUB_CLIENT_ID: 'test_github_client_id' };
Object.defineProperty(import.meta, 'env', { value: mockEnv, writable: true });

// Alert & fetch mocks
const mockAlert = vi.fn();
// @ts-ignore
global.alert = mockAlert;
const mockFetch = vi.fn();
// @ts-ignore
global.fetch = mockFetch;

// Location mock utilities
const originalLocation = window.location;
function mockLocation(href = 'http://localhost:5173/') {
  Object.defineProperty(window, 'location', {
    configurable: true,
    value: {
      href,
      origin: 'http://localhost:5173',
      pathname: '/',
      search: '',
      assign: vi.fn(function (url: string | URL) { (window.location as any).href = String(url); }),
    },
  });
}

const Wrapper = (p: any) => p.children;

describe('Login Component', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockLocation();
    mockEnv.VITE_GITHUB_CLIENT_ID = 'test_github_client_id';
    loginSpy.mockReset();
  });
  afterAll(() => {
    Object.defineProperty(window, 'location', { configurable: true, value: originalLocation });
  });

  describe('Rendering', () => {
    it('renders title', () => {
      render(() => <Login />, { wrapper: Wrapper });
      expect(screen.getByText('Welcome to Hivemind')).toBeInTheDocument();
    });
    it('renders GitHub button', () => {
      render(() => <Login />, { wrapper: Wrapper });
      expect(screen.getByText(/Sign in with GitHub/)).toBeInTheDocument();
    });
    it('renders Mock Login button', () => {
      render(() => <Login />, { wrapper: Wrapper });
      expect(screen.getByText(/Mock Login/)).toBeInTheDocument();
    });
  });

  describe('GitHub OAuth', () => {
    it('redirects to GitHub OAuth (uses provided client id prop)', () => {
      render(() => <Login clientId="abc123" />, { wrapper: Wrapper });
      fireEvent.click(screen.getByText(/Sign in with GitHub/));
      expect(window.location.href).toBe('https://github.com/login/oauth/authorize?client_id=abc123&redirect_uri=http://localhost:5173/auth/callback&scope=user:email');
    });
    it('alerts when client id equals placeholder value', () => {
      mockAlert.mockClear();
      mockLocation();
      render(() => <Login clientId="test_client_id" />, { wrapper: Wrapper });
      fireEvent.click(screen.getByText(/Sign in with GitHub/));
      expect(mockAlert).toHaveBeenCalled();
      expect(window.location.href).toBe('http://localhost:5173/');
    });
  });

  describe('Mock Login', () => {
    it('calls mock endpoint, invokes login, and navigates home', async () => {
      const mockToken = 'mock_jwt_token';
      mockFetch.mockResolvedValueOnce({ ok: true, status: 200, json: () => Promise.resolve({ token: mockToken }) });
      render(() => <Login />, { wrapper: Wrapper });
      fireEvent.click(screen.getByText(/Mock Login/));
      await waitFor(() => {
        expect(mockFetch).toHaveBeenCalledWith('http://localhost:3000/auth/mock/login', expect.objectContaining({ method: 'POST' }));
        expect(loginSpy).toHaveBeenCalledWith(mockToken, undefined);
        expect(navigateSpy).toHaveBeenCalledWith('/');
      });
    });
    it('handles missing token', async () => {
      mockFetch.mockResolvedValueOnce({ ok: true, status: 200, json: () => Promise.resolve({}) });
      render(() => <Login />, { wrapper: Wrapper });
      fireEvent.click(screen.getByText(/Mock Login/));
      await waitFor(() => {
        expect(loginSpy).not.toHaveBeenCalled();
        expect(mockAlert).toHaveBeenCalled();
      });
    });
    it('handles failed mock login', async () => {
      const consoleError = vi.spyOn(console, 'error').mockImplementation(() => { });
      mockFetch.mockRejectedValueOnce(new Error('Network error'));
      render(() => <Login />, { wrapper: Wrapper });
      fireEvent.click(screen.getByText(/Mock Login/));
      await waitFor(() => {
        expect(consoleError).toHaveBeenCalled();
        expect(mockAlert).toHaveBeenCalled();
      });
      consoleError.mockRestore();
    });
  });
});
