// Shared UI types for GraphQL results

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

export interface CharacterFact {
  id: string
  fact: string
  createdAt: string
  updatedAt: string
}

export interface Character {
  id: string
  name: string
  description?: string
  alternateNames: string[]
  tags: string[]
  facts: CharacterFact[]
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
