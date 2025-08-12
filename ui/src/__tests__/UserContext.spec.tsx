import { render } from 'solid-js/web';
import { AuthProvider, useAuth } from '../UserContext';
import { createSignal } from 'solid-js';

describe('UserContext', () => {
  let container: HTMLElement;

  beforeAll(() => {
    const localStorageMock = (() => {
      let store: Record<string, string> = {};
      return {
        getItem: (key: string) => store[key] || null,
        setItem: (key: string, value: string) => {
          store[key] = value;
        },
        removeItem: (key: string) => {
          delete store[key];
        },
        clear: () => {
          store = {};
        },
      };
    })();

    Object.defineProperty(global, 'localStorage', {
      value: localStorageMock,
      writable: true,
    });
  });

  beforeEach(() => {
    container = document.createElement('div');
    document.body.appendChild(container);
    localStorage.clear();
  });

  afterEach(() => {
    document.body.removeChild(container);
  });

  it('should initialize with default state', () => {
    const TestComponent = () => {
      const [store] = useAuth();
      return <div>{store.isAuthenticated ? 'Authenticated' : 'Not Authenticated'}</div>;
    };

    render(() => (
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    ), container);

    expect(container.textContent).toBe('Not Authenticated');
  });

  it('should login and update state', async () => {
    const TestComponent = () => {
      const [store, { login }] = useAuth();
      const [status, setStatus] = createSignal('');

      const handleLogin = async () => {
        await login('test_token', { id: '1', name: 'Test User' });
        setStatus(store.isAuthenticated ? 'Authenticated' : 'Not Authenticated');
      };

      return (
        <div>
          <button onClick={handleLogin}>Login</button>
          <div>{status()}</div>
        </div>
      );
    };

    render(() => (
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    ), container);

    const button = container.querySelector('button');
    button?.click();

    await new Promise((resolve) => setTimeout(resolve, 0)); // Wait for state update

    expect(localStorage.getItem('auth_token')).toBe('test_token');
    expect(localStorage.getItem('user_info')).toBe(JSON.stringify({ id: '1', name: 'Test User' }));
    expect(container.textContent).toContain('Authenticated');
  });

  it('should logout and clear state', () => {
    const TestComponent = () => {
      const [store, { logout }] = useAuth();
      const [status, setStatus] = createSignal('');

      const handleLogout = () => {
        logout();
        setStatus(store.isAuthenticated ? 'Authenticated' : 'Not Authenticated');
      };

      return (
        <div>
          <button onClick={handleLogout}>Logout</button>
          <div>{status()}</div>
        </div>
      );
    };

    localStorage.setItem('auth_token', 'test_token');
    localStorage.setItem('user_info', JSON.stringify({ id: '1', name: 'Test User' }));

    render(() => (
      <AuthProvider>
        <TestComponent />
      </AuthProvider>
    ), container);

    const button = container.querySelector('button');
    button?.click();

    expect(localStorage.getItem('auth_token')).toBeNull();
    expect(localStorage.getItem('user_info')).toBeNull();
    expect(container.textContent).toContain('Not Authenticated');
  });
});
