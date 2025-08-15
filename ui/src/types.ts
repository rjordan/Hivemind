// Shared UI types for API models and GraphQL results

export interface User {
  id: string
  name: string
  email?: string
  admin: boolean
  avatar_url?: string
  github_username?: string
}

export interface Conversation {
  id: string
  title: string
  assistant: string
  scenario: string
  initialMessage: string
  createdAt: string
  updatedAt: string
}

interface CharacterTrait {
  traitType: string
  value: string
}

export interface Character {
  id: string
  name: string
  alternateNames: string[]
  tags: string[]
  traits: CharacterTrait[]
  createdAt: string
  updatedAt: string
}

export interface PageInfo {
  hasNextPage: boolean
  hasPreviousPage: boolean
  startCursor: string
  endCursor: string
}

export interface Edge<T> {
  node: T
}

export interface Connection<T> {
  edges: Edge<T>[]
  pageInfo: PageInfo
}

// Example query result shapes
export interface ConversationsQuery {
  conversations: Connection<Conversation>
}

export interface CharactersQuery {
  characters: Connection<Character>
}
