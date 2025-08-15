import { gql } from '@solid-primitives/graphql'
import config from './config.json'
import type { ConversationsQuery, User, CharactersQuery } from './types'

const HIVEMIND_API_URL = `${config.apiBaseUrl}/graphql`

const GET_CONVERSATIONS = gql`
  query ($limit: Int, $cursor: String) {
    conversations(last: $limit, after: $cursor) {
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

const GET_CHARACTERS = gql`
  query ($includePublic: Boolean, $limit: Int, $cursor: String) {
    characters(includePublic: $includePublic, last: $limit, after: $cursor) {
      edges {
        node {
          id
          name
          alternateNames
          tags
          traits {
            traitType
            value
          }
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

const GET_CURRENT_USER = gql`
  query {
    currentUser {
      id
      email
      name
      admin
      personas {
        id
        name
        description
      }
      characters {
        id
        name
        alternateNames
        tags
      }
      conversations {
        id
        title
        scenario
      }
    }
  }
`

const sendGraphQLQuery = async (authToken: string | null, query: string, variables: unknown = {}) => {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  }
  if (authToken) headers.Authorization = `Bearer ${authToken}`

  const response = await fetch(HIVEMIND_API_URL, {
    method: 'POST',
    headers,
    body: JSON.stringify({ query: query, variables: variables }),
  })
  console.debug(`GraphQL Response: ${response.status} ${response.statusText}`)

  const data = await response.json()
  return data.data
}

export const getCurrentUser = async (authToken: string | null): Promise<User | null> => {
  const response = await sendGraphQLQuery(authToken, GET_CURRENT_USER)
  return response.currentUser
}

export const getConversations = async (authToken: string | null, limit: number = 50, cursor: string | null = null): Promise<ConversationsQuery> => {
  const response = await sendGraphQLQuery(authToken, GET_CONVERSATIONS, { limit: limit, cursor: cursor })
  const conversations = response?.conversations ?? {
    edges: [],
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
      startCursor: '',
      endCursor: '',
    },
  }
  return { conversations }
}

export const getCharacters = async (authToken: string | null, includePublic: boolean = false, limit: number = 50, cursor: string = null): Promise<CharactersQuery> => {
  const response = await sendGraphQLQuery(authToken, GET_CHARACTERS, { includePublic, limit, cursor })
  const characters = response?.characters ?? {
    edges: [],
    pageInfo: {
      hasNextPage: false,
      hasPreviousPage: false,
      startCursor: '',
      endCursor: '',
    },
  }
  return { characters }
}
