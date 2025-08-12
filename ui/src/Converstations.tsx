import { createEffect, createSignal, For, createMemo } from 'solid-js'
import { createGraphQLClient, gql } from '@solid-primitives/graphql'
import { useAuth } from './UserContext'
import config from './config.json'

const GET_CONVERSATIONS = gql`
  query {
    conversations {
      edges {
        node {
          id
          title
          assistant
          scenario
          initialMessage
          createdAt
          updatedAt
        }
      }
      pageInfo {
        hasNextPage
        hasPreviousPage
        startCursor
        endCursor
      }
    }
  }
`

type Conversation = {
  id: string;
  title: string;
  assistant: string;
  scenario: string;
  initialMessage: string;
  createdAt: string;
  updatedAt: string;
};

type ConversationConnection = {
  conversations: {
    edges: { node: Conversation }[];
    pageInfo: {
      hasNextPage: boolean;
      hasPreviousPage: boolean;
      startCursor: string;
      endCursor: string;
    };
  };
};


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
  const [authStore] = useAuth()
  const [conversations, setConversations] = createSignal<Conversation[]>([])

  // Re-create the GraphQL client whenever the auth token changes so the header stays in sync.
  const graphqlClient = createMemo(() =>
    createGraphQLClient(`${config.apiBaseUrl}/graphql`, {
      headers: {
        Authorization: `Bearer ${authStore.token || ''}`
      }
    })
  )

  // Execute the query using the current client (reacts to token changes)
  const [conversationResult] = graphqlClient()<ConversationConnection>(GET_CONVERSATIONS)

  createEffect(() => {
    // Track the cursor to allow pagination
    setConversations((prev) => [
      ...prev,
      ...(conversationResult()?.conversations.edges.map((e) => e.node) || []),
    ])
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

      {/* Card Grid View */}
      <div class="conversations__grid">
        <For each={conversations()}>
          {(story) => <ConversationCard {...story} />}
        </For>
      </div>

    </div>
  )
}

export default Conversations
