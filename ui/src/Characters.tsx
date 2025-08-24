import { createEffect, createSignal, For, Show } from 'solid-js'
import { useAuth } from './UserContext'
import type { Character } from './types'
import { getCharacters } from './hivemind_svc'
import CreateCharacterModal from './CreateCharacterModal'

function CharacterCard(char: Character) {
  return <div class="characters__card" data-id={char.id}>
    <div class="characters__card-header">
      <h4>{char.name}</h4>
    </div>
    <div class="characters__card-body">
      {char.description && (
        <p class="characters__card-description">{char.description}</p>
      )}

      {char.tags && char.tags.length > 0 && (
        <div class="characters__tags">
          <For each={char.tags}>{(tag, index) =>
            <span class={`characters__tag ${index() === 0 ? 'characters__tag--highlight' : ''}`}>
              🏷️ {tag}
            </span>
          }</For>
        </div>
      )}

      {char.alternateNames && char.alternateNames.length > 0 && (
        <p class="characters__card-alternate-names">Also known as: {char.alternateNames.join(', ')}</p>
      )}

      <div class="characters__card-actions">
        <button class="characters__card-button">
          View Character →
        </button>
      </div>
    </div>
  </div>
}

const Characters = () => {
  const [, { getToken }] = useAuth()
  const [characters, setCharacters] = createSignal<Character[]>([])
  const [isLoading, setIsLoading] = createSignal<boolean>(true)
  const [isModalOpen, setIsModalOpen] = createSignal<boolean>(false)

  const loadCharacters = () => {
    setIsLoading(true)
    getCharacters(getToken())
      .then((result) => {
        const next = result?.characters?.edges?.map((e) => e.node) || []
        setCharacters(next)
      })
      .catch((err) => {
        console.error('Failed to fetch characters:', err)
      })
      .finally(() => setIsLoading(false))
  }

  createEffect(() => {
    loadCharacters()
  })

  const handleCharacterCreated = (newCharacter: Character) => {
    setCharacters(prev => [newCharacter, ...prev])
  }

  return (
    <div class="characters">
      <div class="characters__header">
        <h1 class="characters__title">Characters</h1>
        <p class="characters__subtitle">Browse available AI characters</p>
      </div>

      <button
        class="characters__new-button"
        onClick={() => setIsModalOpen(true)}
      >
        Create New Character
      </button>

      <CreateCharacterModal
        isOpen={isModalOpen()}
        onClose={() => setIsModalOpen(false)}
        onCharacterCreated={handleCharacterCreated}
      />

      <Show when={!isLoading()} fallback={
        <div class="characters__grid">
          <div class="characters__card skeleton" />
          <div class="characters__card skeleton" />
          <div class="characters__card skeleton" />
        </div>
      }>
        <div class="characters__grid">
          <For each={characters()}>
            {(char) => <CharacterCard {...char} />}
          </For>
        </div>
      </Show>
    </div>
  )
}

export default Characters
