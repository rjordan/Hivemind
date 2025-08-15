import { createEffect, createSignal, For, Show } from 'solid-js'
import { useAuth } from './UserContext'
import type { Conversation } from './types'
import { getConversations } from './hivemind_svc'

function ConversationCard(story: Conversation) {
  console.log(`Card: ${JSON.stringify(story)}`)
  return <div class="conversations__card" data-id={story.id}>
    <div class="conversations__card-header">
      <h4>{story.title}</h4>
    </div>
    <div class="conversations__card-body">
      <p class="conversations__card-description">{story.scenario}</p>
      <div class="conversations__card-actions">
        <button class="conversations__card-button">
          Open Conversation →
        </button>
      </div>
    </div>
  </div>
}

const Conversations = () => {
  const [, { getToken }] = useAuth()
  const [conversations, setConversations] = createSignal<Conversation[]>([])
  const [isLoading, setIsLoading] = createSignal<boolean>(true)

  // Execute the query using the current client (reacts to token changes)
  createEffect(() => {
    setIsLoading(true)
    getConversations(getToken())
      .then((result) => {
        const next = result?.conversations?.edges?.map((e) => e.node) || []
        setConversations((prev) => [...prev, ...next])
      })
      .catch(() => {
        // Optionally: surface error UI later
      })
      .finally(() => setIsLoading(false))
  })

  return (
    <div class="conversations">
      <div class="conversations__header">
        <h1 class="conversations__title">Conversations</h1>
        <p class="conversations__subtitle">Manage and explore your AI conversations</p>
      </div>

      <button class="conversations__new-button">
        Start New Conversation
      </button>

      {/* Loading skeleton or Card Grid View */}
      <Show when={!isLoading()} fallback={
        <div class="conversations__grid">
          <div class="conversations__card skeleton" />
          <div class="conversations__card skeleton" />
          <div class="conversations__card skeleton" />
        </div>
      }>
        <div class="conversations__grid">
          <For each={conversations()}>
            {(story) => <ConversationCard {...story} />}
          </For>
        </div>
      </Show>

    </div>
  )
}

export default Conversations
