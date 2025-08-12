import { Show } from 'solid-js'
import { useAuth } from './UserContext'

const Home = () => {
  const [authStore] = useAuth()

  return (
    <div class="container mx-auto px-4 py-8">
      <Show when={authStore.isAuthenticated} fallback={
        <div class="text-center">
          <h1 class="text-4xl font-bold mb-4">Welcome to Hivemind</h1>
          <p class="text-xl text-gray-600 mb-8">
            Your AI-powered conversation platform
          </p>
          <div class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-2xl font-semibold mb-4">Get Started</h2>
            <p class="text-gray-700 mb-4">
              Sign in with GitHub to start having conversations with AI characters and manage your personas.
            </p>
            <a href="/login" class="inline-block bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors">
              Get Started →
            </a>
          </div>
        </div>
      }>
        <div class="text-center">
          <h1 class="text-4xl font-bold mb-4">Welcome back, {authStore.user?.name}!</h1>
          <p class="text-xl text-gray-600 mb-8">
            Ready to dive into your conversations?
          </p>
          <div class="grid md:grid-cols-3 gap-6">
            <div class="bg-white rounded-lg shadow-md p-6">
              <h3 class="text-xl font-semibold mb-3">💬 Conversations</h3>
              <p class="text-gray-600 mb-4">Continue your ongoing conversations with AI characters</p>
              <a href="/conversations" class="text-blue-600 hover:text-blue-800">View Conversations →</a>
            </div>
            <div class="bg-white rounded-lg shadow-md p-6">
              <h3 class="text-xl font-semibold mb-3">👥 Characters</h3>
              <p class="text-gray-600 mb-4">Meet new AI characters and personalities</p>
              <a href="#" class="text-blue-600 hover:text-blue-800">Explore Characters →</a>
            </div>
            <div class="bg-white rounded-lg shadow-md p-6">
              <h3 class="text-xl font-semibold mb-3">📋 Personas</h3>
              <p class="text-gray-600 mb-4">Manage your different conversation personas</p>
              <a href="#" class="text-blue-600 hover:text-blue-800">Manage Personas →</a>
            </div>
          </div>
        </div>
      </Show>
    </div>
  )
}

export default Home
