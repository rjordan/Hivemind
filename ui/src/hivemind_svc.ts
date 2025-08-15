import { gql } from '@solid-primitives/graphql'
import config from './config.json'
import type { ConversationsQuery, User } from './types'

const HIVEMIND_API_URL = `${config.apiBaseUrl}/graphql`

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

const sendGraphQLQuery = async (authToken: string | null, query: string) => {
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  }
  if (authToken) headers.Authorization = `Bearer ${authToken}`

  const response = await fetch(HIVEMIND_API_URL, {
    method: 'POST',
    headers,
    body: JSON.stringify({ query: query }),
  })
  console.debug(`GraphQL Response: ${response.status} ${response.statusText}`)

  const data = await response.json()
  return data.data
}

export const getCurrentUser = async (authToken: string | null): Promise<User | null> => {
  const response = await sendGraphQLQuery(authToken, GET_CURRENT_USER)
  return response.currentUser
}

export const getConversations = async (authToken: string | null): Promise<ConversationsQuery> => {
  const response = await sendGraphQLQuery(authToken, GET_CONVERSATIONS)
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
