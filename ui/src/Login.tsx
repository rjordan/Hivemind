import { Component } from 'solid-js'
import { useNavigate } from '@solidjs/router'
import { useAuth } from './UserContext'
import config from './config.json'

export const generateGitHubAuthUrl = (clientId: string, redirectUri: string, scope: string): string =>
  `https://github.com/login/oauth/authorize?client_id=${clientId}&redirect_uri=${redirectUri}&scope=${scope}`

type LoginProps = {
  clientId?: string; // test override
};

const Login: Component<LoginProps> = (props) => {
  const [, { login }] = useAuth()
  const navigate = useNavigate()

  const handleGitHubLogin = () => {
    const clientId = props.clientId ?? import.meta.env.VITE_GITHUB_CLIENT_ID
    if (!clientId || clientId === 'test_client_id') {
      alert('GitHub OAuth is not configured. Please set up your GitHub OAuth app and configure the environment variables. See AUTH_SETUP.md for instructions.')
      return
    }

    const redirectUri = `${window.location.origin}/auth/callback`
    const scope = 'user:email'
    window.location.href = generateGitHubAuthUrl(clientId, redirectUri, scope)
  }

  const handleMockLogin = async () => {
    try {
      const response = await fetch(`${config.apiBaseUrl}/auth/mock/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })

      if (!response.ok) {
        console.error('Mock login HTTP error', response.status, await response.text())
        throw new Error('Mock login request failed')
      }

      const data = await response.json()

      if (data?.token) {
        await login(data.token, data.user)
        // After successful mock login, redirect home for parity with OAuth flow
        navigate('/')
      } else {
        console.error('Mock login response missing token payload:', data)
        throw new Error('No token received')
      }
    } catch (error) {
      console.error('Mock login failed:', error)
      alert('Mock login failed. Check console for details.')
    }
  }

  return (
    <div class="login">
      <div class="login__container">
        <div class="login__card">
          <div class="login__header">
            <h1 class="login__title">Welcome to Hivemind</h1>
            <p class="login__subtitle">Sign in to continue to your conversations</p>
          </div>

          <div class="login__content">
            <button
              class="login__github-button"
              onClick={handleGitHubLogin}
            >
              <svg class="login__github-icon" viewBox="0 0 16 16" width="20" height="20">
                <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
              </svg>
              Sign in with GitHub
            </button>

            {/* Development-only mock login button */}
            <button
              class="login__github-button"
              onClick={handleMockLogin}
              style={{ 'margin-top': '1rem', 'background': '#059669' }}
            >
              🧪 Mock Login (Development Only)
            </button>
          </div>

          <div class="login__footer">
            <p class="login__help-text">
              By signing in, you agree to our terms of service and privacy policy.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Login
