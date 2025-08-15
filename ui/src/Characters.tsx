import { createEffect, createSignal, For, Show } from 'solid-js'
import { useAuth } from './UserContext'
import type { Character } from './types'
import { getCharacters } from './hivemind_svc'

function CharacterCard(char: Character) {
  return <div class="characters__card" data-id={char.id}>
    <div class="characters__card-header">
      <h4>{char.name}</h4>
    </div>
    <div class="characters__card-body">
      <p class="characters__card-description">{char.alternateNames?.join(', ')}</p>
      <div class="characters__tags">
        <For each={char.tags}>{(t) => <span class="characters__tag">{t}</span>}</For>
      </div>
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

  createEffect(() => {
    setIsLoading(true)
    getCharacters(getToken())
      .then((result) => {
        const next = result?.characters?.edges?.map((e) => e.node) || []
        setCharacters(next)
      })
      .catch(() => {})
      .finally(() => setIsLoading(false))
  })

  return (
    <div class="characters">
      <div class="characters__header">
        <h1 class="characters__title">Characters</h1>
        <p class="characters__subtitle">Browse available AI characters</p>
      </div>

      <button class="characters__new-button">
        Create New Character
      </button>

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
