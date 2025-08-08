import { createEffect, createResource, For } from "solid-js";
// import config from './config.json';

const config = {
  apiBaseUrl: "http://localhost:3001"
}

const fetchConversations = async () => {
  console.log('Fetching conversations from:', config.apiBaseUrl);
  const response = await fetch(`${config.apiBaseUrl}/api/conversations`);
  if (!response.ok) {
    throw new Error('Failed to fetch stories');
  }
  return response.json();
}

const Conversations = () => {
  const [conversations, { mutate, refetch }] = createResource({}, fetchConversations)

  createEffect(() => {
    console.log('Conversations loaded:', conversations());
  })

  return (
    <div class="conversations">
      <div class="conversations__header">
        <h1 class="conversations__title">💬 Conversations</h1>
        <p class="conversations__subtitle">Manage and explore your AI conversations</p>
      </div>

      {conversations.loading && (
        <div class="conversations__loading">
          Loading conversations...
        </div>
      )}

      {conversations.error && (
        <div class="conversations__error">
          <div class="conversations__error-icon">⚠️</div>
          <div class="conversations__error-message">Error loading conversations</div>
          <div class="conversations__error-description">{conversations.error.message}</div>
          <button class="conversations__error-retry" onClick={() => refetch()}>
            Try Again
          </button>
        </div>
      )}

      {/* Card Grid View */}
      <div class="conversations__grid">
        <For each={conversations()}>
          {(story) => (
            <div class="conversations__card" data-id={story.id}>
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
          )}
        </For>
      </div>

    </div>
  );
};

export default Conversations;
