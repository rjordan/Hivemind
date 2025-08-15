import { Component, createEffect } from 'solid-js'
import { useNavigate, useSearchParams } from '@solidjs/router'
import { useAuth } from './UserContext'
import config from './config.json'

const AuthCallback: Component = () => {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const [, { login }] = useAuth()

  createEffect(async () => {
    const code = searchParams.code
    const error = searchParams.error

    if (error) {
      console.error('OAuth error:', error)
      navigate('/login')
      return
    }

    if (!code) {
      navigate('/login')
      return
    }

    try {
      // Exchange the code for an access token via your backend
      const response = await fetch(`${config.apiBaseUrl}/auth/github/callback`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ code }),
      })

      const data = await response.json()

      if (data.token) {
        // Pass user data if available from the backend
        await login(data.token)
        navigate('/')
      } else {
        throw new Error('No token received')
      }
    } catch (error) {
      console.error('Failed to exchange OAuth code:', error)
      navigate('/login')
    }
  })

  return (
    <div class="auth-callback">
      <div class="auth-callback__container">
        <div class="auth-callback__loading">
          <div class="auth-callback__spinner"></div>
          <p>Completing sign in...</p>
        </div>
      </div>
    </div>
  )
}

export default AuthCallback
