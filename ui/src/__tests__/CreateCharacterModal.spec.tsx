/* eslint-disable @typescript-eslint/no-explicit-any */
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, fireEvent, waitFor } from '@solidjs/testing-library'
import userEvent from '@testing-library/user-event'
import CreateCharacterModal from '../CreateCharacterModal'
import type { JSX } from 'solid-js'

vi.mock('../UserContext')
import { AuthProvider } from '../UserContext'

// Mock config used by service
vi.mock('../config.json', () => ({ default: { apiBaseUrl: 'http://localhost:3000' } }))

// Mock service calls
const getAvailableModelsMock = vi.fn(async (_token: string | null) => ['gpt-4', 'gpt-3.5-turbo', 'claude-3-sonnet'])

const createCharacterMock = vi.fn(async (_token: string | null, _input: any) => ({
  character: {
    id: '123',
    name: 'Test Character',
    alternateNames: ['Alias'],
    tags: ['test'],
    description: 'Test description',
    model: 'gpt-4',
    facts: [],
    createdAt: '2025-08-24T00:00:00Z',
    updatedAt: '2025-08-24T00:00:00Z'
  },
  errors: []
}))

vi.mock('../hivemind_svc', () => ({
  getAvailableModels: (token: string | null) => getAvailableModelsMock(token),
  createCharacter: (token: string | null, input: any) => createCharacterMock(token, input)
}))

import * as UC from '../UserContext'
const mockAuthStore: any = (UC as any).mockAuthStore
function setAuth(partial: Partial<typeof mockAuthStore>) { Object.assign(mockAuthStore, partial) }

const Wrapper = (props: { children: JSX.Element }) => <AuthProvider>{props.children}</AuthProvider>

describe('CreateCharacterModal Component', () => {
  const mockOnClose = vi.fn()
  const mockOnCharacterCreated = vi.fn()

  const defaultProps = {
    isOpen: true,
    onClose: mockOnClose,
    onCharacterCreated: mockOnCharacterCreated
  }

  beforeEach(() => {
    vi.clearAllMocks()
    setAuth({
      isAuthenticated: true,
      isLoading: false,
      token: 'mock_token',
      user: { id: 'u', name: 'Test' }
    })
  })

  describe('Modal Rendering', () => {
    it('renders modal when isOpen is true', async () => {
      render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

      await waitFor(() => {
        expect(screen.getByText('Create Character')).toBeInTheDocument()
      })

      expect(screen.getByPlaceholderText('Enter character name')).toBeInTheDocument()
      expect(screen.getByPlaceholderText('Describe the character\'s personality, background, and traits')).toBeInTheDocument()
      expect(screen.getByText('Alternate Names')).toBeInTheDocument()
      expect(screen.getByText('Tags')).toBeInTheDocument()
    })

    it('does not render modal when isOpen is false', () => {
      render(() => <CreateCharacterModal {...defaultProps} isOpen={false} />, { wrapper: Wrapper })

      expect(screen.queryByText('Create Character')).not.toBeInTheDocument()
    })

    it('loads and displays available models in dropdown', async () => {
      render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

      await waitFor(() => {
        expect(getAvailableModelsMock).toHaveBeenCalledWith('mock_token')
      })

      // Should have a model select element
      const modelSelect = screen.getByLabelText('Default Model *')
      expect(modelSelect).toBeInTheDocument()

      // Wait for the options to be populated - this might take time due to the async data loading
      await waitFor(() => {
        expect(screen.getByText('gpt-4')).toBeInTheDocument()
      }, { timeout: 3000 })
    })
  })

  describe('Form Interactions', () => {
    it('updates form fields correctly', async () => {
      const user = userEvent.setup()
      render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Enter character name')).toBeInTheDocument()
      })

      const nameInput = screen.getByPlaceholderText('Enter character name')
      const descriptionInput = screen.getByPlaceholderText('Describe the character\'s personality, background, and traits')

      await user.type(nameInput, 'Test Character')
      await user.type(descriptionInput, 'Test description')

      expect(nameInput).toHaveValue('Test Character')
      expect(descriptionInput).toHaveValue('Test description')
    })
  })

  describe('Array Input Functionality', () => {
    describe('Alternate Names', () => {
      it('adds alternate names to the list', async () => {
        const user = userEvent.setup()
        render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

        await waitFor(() => {
          expect(screen.getByText('Alternate Names')).toBeInTheDocument()
        })

        const input = screen.getByPlaceholderText('Enter alternate name')
        const addButton = screen.getByLabelText('Add alternate name')

        await user.type(input, 'The One')
        await user.click(addButton)

        expect(screen.getByText('The One')).toBeInTheDocument()
        expect(input).toHaveValue('') // Input should be cleared after adding
      })

      it('removes alternate names from the list', async () => {
        const user = userEvent.setup()
        render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

        await waitFor(() => {
          expect(screen.getByText('Alternate Names')).toBeInTheDocument()
        })

        const input = screen.getByPlaceholderText('Enter alternate name')
        const addButton = screen.getByLabelText('Add alternate name')

        // Add an alternate name
        await user.type(input, 'Neo')
        await user.click(addButton)

        expect(screen.getByText('Neo')).toBeInTheDocument()

        // Remove the alternate name
        const removeButton = screen.getByLabelText('Remove Neo')
        await user.click(removeButton)

        expect(screen.queryByText('Neo')).not.toBeInTheDocument()
      })

      it('allows adding alternate names by pressing Enter', async () => {
        const user = userEvent.setup()
        render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

        await waitFor(() => {
          expect(screen.getByText('Alternate Names')).toBeInTheDocument()
        })

        const input = screen.getByPlaceholderText('Enter alternate name')

        await user.type(input, 'Agent Smith')
        await user.keyboard('{Enter}')

        expect(screen.getByText('Agent Smith')).toBeInTheDocument()
        expect(input).toHaveValue('')
      })
    })

    describe('Tags', () => {
      it('adds tags to the list', async () => {
        const user = userEvent.setup()
        render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

        await waitFor(() => {
          expect(screen.getByText('Tags')).toBeInTheDocument()
        })

        const input = screen.getByPlaceholderText('Enter tag')
        const addButton = screen.getByLabelText('Add tag')

        await user.type(input, 'hero')
        await user.click(addButton)

        expect(screen.getByText('hero')).toBeInTheDocument()
        expect(input).toHaveValue('')
      })

      it('allows adding tags by pressing Enter', async () => {
        const user = userEvent.setup()
        render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

        await waitFor(() => {
          expect(screen.getByText('Tags')).toBeInTheDocument()
        })

        const input = screen.getByPlaceholderText('Enter tag')

        await user.type(input, 'protagonist')
        await user.keyboard('{Enter}')

        expect(screen.getByText('protagonist')).toBeInTheDocument()
        expect(input).toHaveValue('')
      })
    })
  })

  describe('Form Submission', () => {
    it('creates character with correct data including arrays', async () => {
      const user = userEvent.setup()
      render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Enter character name')).toBeInTheDocument()
      })

      // Fill out form
      await user.type(screen.getByPlaceholderText('Enter character name'), 'Neo')
      await user.type(screen.getByPlaceholderText('Describe the character\'s personality, background, and traits'), 'The chosen one')

      // Add alternate names
      const altNameInput = screen.getByPlaceholderText('Enter alternate name')
      await user.type(altNameInput, 'The One')
      await user.click(screen.getByLabelText('Add alternate name'))

      // Add tags
      const tagInput = screen.getByPlaceholderText('Enter tag')
      await user.type(tagInput, 'hero')
      await user.click(screen.getByLabelText('Add tag'))

      // Submit form
      const createButton = screen.getByText('Create Character')
      await user.click(createButton)

      await waitFor(() => {
        expect(createCharacterMock).toHaveBeenCalledWith('mock_token', {
          name: 'Neo',
          description: 'The chosen one',
          alternateNames: ['The One'],
          tags: ['hero'],
          defaultModel: 'gpt-4',
          isPublic: false
        })
      })

      expect(mockOnCharacterCreated).toHaveBeenCalled()
      expect(mockOnClose).toHaveBeenCalled()
    })

    it('validates required fields and shows error messages', async () => {
      const user = userEvent.setup()
      render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

      await waitFor(() => {
        expect(screen.getByPlaceholderText('Enter character name')).toBeInTheDocument()
      })

      // First fill in the required fields to enable the submit button
      const nameInput = screen.getByPlaceholderText('Enter character name')
      const descriptionInput = screen.getByPlaceholderText('Describe the character\'s personality, background, and traits')

      await user.type(nameInput, 'Test Name')
      await user.type(descriptionInput, 'Test description')

      // Wait for button to be enabled
      await waitFor(() => {
        const createButton = screen.getByText('Create Character')
        expect(createButton).not.toBeDisabled()
      })

      // Now clear the fields to make them invalid
      await user.clear(nameInput)
      await user.clear(descriptionInput)

      // Force the form submission even though button is disabled (in real world, user can't do this)
      // We'll simulate a form submission event directly
      const form = screen.getByRole('form')
      fireEvent.submit(form)

      await waitFor(() => {
        expect(screen.getByText('Name is required')).toBeInTheDocument()
        expect(screen.getByText('Description is required')).toBeInTheDocument()
      })

      // Form should not be submitted
      expect(createCharacterMock).not.toHaveBeenCalled()
      expect(mockOnCharacterCreated).not.toHaveBeenCalled()
      expect(mockOnClose).not.toHaveBeenCalled()
    })
  })

  describe('Modal Controls', () => {
    it('closes modal when clicking cancel button', async () => {
      const user = userEvent.setup()
      render(() => <CreateCharacterModal {...defaultProps} />, { wrapper: Wrapper })

      await waitFor(() => {
        expect(screen.getByText('Create Character')).toBeInTheDocument()
      })

      const cancelButton = screen.getByText('Cancel')
      await user.click(cancelButton)

      expect(mockOnClose).toHaveBeenCalled()
    })
  })
})
