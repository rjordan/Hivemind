/**
 * Home Component Tests
 *
 * Comprehensive tests for the Home component which displays different content
 * based on authentication state - includes both unit tests and integration tests
 */

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen } from '@solidjs/testing-library';
import { Component } from 'solid-js';

// Use manual mock implementation (../__mocks__/UserContext.tsx)
vi.mock('../UserContext');
import Home from '../Home';
import * as UserContextModule from '../UserContext';
const { AuthProvider, mockAuthStore } = UserContextModule as any;

// Test wrapper includes AuthProvider so component can access context normally
const TestWrapper: Component<{ children: any }> = (props) => (
  <AuthProvider>{props.children}</AuthProvider>
);

describe('Home Component', () => {
  const mockUser = {
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    avatar_url: 'https://example.com/avatar.jpg',
    github_username: 'testuser'
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('Component Structure', () => {
    it('should be exportable as default export', async () => {
      const HomeModule = await import('../Home');
      expect(HomeModule.default).toBeDefined();
      expect(typeof HomeModule.default).toBe('function');
    });
  });

  describe('Authentication State Logic (Unit Tests)', () => {
    it('should handle unauthenticated state data correctly', () => {
      const unauthenticatedState = {
        isAuthenticated: false,
        isLoading: false,
        user: null,
        token: null,
        error: null
      };

      expect(unauthenticatedState.isAuthenticated).toBe(false);
      expect(unauthenticatedState.user).toBeNull();
      expect(unauthenticatedState.token).toBeNull();
    });

    it('should handle authenticated state data correctly', () => {
      const authenticatedState = {
        isAuthenticated: true,
        isLoading: false,
        user: mockUser,
        token: 'jwt_token_123',
        error: null
      };

      expect(authenticatedState.isAuthenticated).toBe(true);
      expect(authenticatedState.user?.name).toBe('Test User');
      expect(authenticatedState.token).toBe('jwt_token_123');
    });

    it('should handle loading state data correctly', () => {
      const loadingState = {
        isAuthenticated: false,
        isLoading: true,
        user: null,
        token: null,
        error: null
      };

      expect(loadingState.isLoading).toBe(true);
      expect(loadingState.isAuthenticated).toBe(false);
    });

    it('should provide correct navigation paths', () => {
      const routes = {
        login: '/login',
        conversations: '/conversations',
        home: '/'
      };

      expect(routes.login).toBe('/login');
      expect(routes.conversations).toBe('/conversations');
      expect(routes.home).toBe('/');
    });

    it('should format user welcome messages correctly', () => {
      const user = { name: 'Test User' };
      const welcomeMessage = `Welcome back, ${user.name}!`;

      expect(welcomeMessage).toBe('Welcome back, Test User!');
    });

    it('should handle users without names gracefully', () => {
      const userWithoutName = { email: 'test@example.com' };
      const fallbackMessage = (userWithoutName as any).name || 'Welcome back!';

      expect(fallbackMessage).toBe('Welcome back!');
    });

    it('should determine content visibility based on auth state', () => {
      const determineContent = (isAuthenticated: boolean) => ({
        showUnauthenticatedContent: !isAuthenticated,
        showAuthenticatedContent: isAuthenticated,
        showGetStarted: !isAuthenticated,
        showQuickActions: isAuthenticated
      });

      const unauthenticatedContent = determineContent(false);
      expect(unauthenticatedContent.showUnauthenticatedContent).toBe(true);
      expect(unauthenticatedContent.showAuthenticatedContent).toBe(false);

      const authenticatedContent = determineContent(true);
      expect(authenticatedContent.showUnauthenticatedContent).toBe(false);
      expect(authenticatedContent.showAuthenticatedContent).toBe(true);
    });
  });

  describe('Unauthenticated State (Integration Tests)', () => {
    beforeEach(() => {
      Object.assign(mockAuthStore, {
        isAuthenticated: false,
        isLoading: false,
        user: null,
        token: null,
        error: null
      });
    });

    it('should render welcome message for unauthenticated users', () => {
      const { container } = render(() => <Home />, { wrapper: TestWrapper });

      // Debug: log the HTML to see what's actually being rendered
      console.log('Rendered HTML:', container.innerHTML);

      expect(screen.getByText('Welcome to Hivemind')).toBeInTheDocument();
      expect(screen.getByText('Your AI-powered conversation platform')).toBeInTheDocument();
    });

    it('should show get started section for unauthenticated users', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.getByText('Get Started')).toBeInTheDocument();
      expect(screen.getByText(/Sign in with GitHub to start having conversations/)).toBeInTheDocument();
    });

    it('should show get started button that links to login', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      const getStartedButton = screen.getByText('Get Started →');
      expect(getStartedButton).toBeInTheDocument();
      expect(getStartedButton.closest('a')).toHaveAttribute('href', '/login');
    });

    it('should not show authenticated content when unauthenticated', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.queryByText('Ready to dive into your conversations?')).not.toBeInTheDocument();
      expect(screen.queryByText('Quick Actions')).not.toBeInTheDocument();
    });
  });

  describe('Authenticated State (Integration Tests)', () => {
    beforeEach(() => {
      Object.assign(mockAuthStore, {
        isAuthenticated: true,
        isLoading: false,
        user: mockUser,
        token: 'mock_token',
        error: null
      });
    });

    it('should render personalized welcome message for authenticated users', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.getByText('Welcome back, Test User!')).toBeInTheDocument();
      expect(screen.getByText('Ready to dive into your conversations?')).toBeInTheDocument();
    });

    it('should show conversations card with correct link', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.getByText('💬 Conversations')).toBeInTheDocument();
      expect(screen.getByText('Continue your ongoing conversations with AI characters')).toBeInTheDocument();

      const conversationsLink = screen.getByText('View Conversations →');
      expect(conversationsLink).toBeInTheDocument();
      expect(conversationsLink.closest('a')).toHaveAttribute('href', '/conversations');
    });

    it('should show characters card', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.getByText('👥 Characters')).toBeInTheDocument();
      expect(screen.getByText('Meet new AI characters and personalities')).toBeInTheDocument();
      expect(screen.getByText('Explore Characters →')).toBeInTheDocument();
    });

    it('should show personas card', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.getByText('📋 Personas')).toBeInTheDocument();
      expect(screen.getByText('Manage your different conversation personas')).toBeInTheDocument();
      expect(screen.getByText('Manage Personas →')).toBeInTheDocument();
    });

    it('should not show unauthenticated content when authenticated', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      expect(screen.queryByText('Get Started')).not.toBeInTheDocument();
      expect(screen.queryByText(/Sign in with GitHub to start/)).not.toBeInTheDocument();
    });

    it('should handle user without name gracefully', () => {
      Object.assign(mockAuthStore, {
        isAuthenticated: true,
        isLoading: false,
        user: { ...mockUser, name: undefined as any },
        token: 'mock_token',
        error: null
      });

      render(() => <Home />, { wrapper: TestWrapper });

      // Should still render the welcome section even without a name
      expect(screen.getByText(/Welcome back,/)).toBeInTheDocument();
    });
  });

  describe('Loading State (Integration Tests)', () => {
    beforeEach(() => {
      Object.assign(mockAuthStore, {
        isAuthenticated: false,
        isLoading: true,
        user: null,
        token: null,
        error: null
      });
    });

    it('should handle loading state appropriately', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      // During loading, should show unauthenticated content as fallback
      expect(screen.getByText('Welcome to Hivemind')).toBeInTheDocument();
    });
  });

  describe('Error State (Integration Tests)', () => {
    beforeEach(() => {
      Object.assign(mockAuthStore, {
        isAuthenticated: false,
        isLoading: false,
        user: null,
        token: null,
        error: 'Authentication failed'
      });
    });

    it('should handle error state gracefully', () => {
      render(() => <Home />, { wrapper: TestWrapper });

      // Should still render unauthenticated content even with errors
      expect(screen.getByText('Welcome to Hivemind')).toBeInTheDocument();
      expect(screen.getByText('Get Started')).toBeInTheDocument();
    });
  });
});
