import { createSignal, createEffect, createMemo, Show, For } from 'solid-js'
import { useAuth } from './UserContext'
import { createCharacter, getAvailableModels } from './hivemind_svc'
import type { Character } from './types'

interface CreateCharacterModalProps {
  isOpen: boolean
  onClose: () => void
  onCharacterCreated?: (character: Character) => void
}

const CreateCharacterModal = (props: CreateCharacterModalProps) => {
  const [, { getToken }] = useAuth()
  const [formData, setFormData] = createSignal({
    name: '',
    description: '',
    defaultModel: 'Llama 3.2',
    isPublic: false
  })
  const [alternateNames, setAlternateNames] = createSignal<string[]>([])
  const [tags, setTags] = createSignal<string[]>([])
  const [newAlternateName, setNewAlternateName] = createSignal('')
  const [newTag, setNewTag] = createSignal('')
  const [availableModels, setAvailableModels] = createSignal<string[]>([])
  const [isSubmitting, setIsSubmitting] = createSignal(false)
  const [errors, setErrors] = createSignal<string[]>([])
  const [fieldErrors, setFieldErrors] = createSignal<Record<string, string>>({})

  // Load available models when modal opens
  createEffect(() => {
    if (props.isOpen) {
      getAvailableModels(getToken())
        .then((models) => {
          setAvailableModels(models)
          // Set first model as default if available
          if (models.length > 0) {
            setFormData(prev => ({ ...prev, defaultModel: models[0] }))
          }
        })
        .catch((err) => {
          console.error('Failed to fetch available models:', err)
        })
    }
  })

  const handleSubmit = async (e: Event) => {
    e.preventDefault()
    setIsSubmitting(true)
    setErrors([])
    setFieldErrors({})

    // Client-side validation
    const data = formData()
    const newFieldErrors: Record<string, string> = {}

    if (!data.name.trim()) {
      newFieldErrors.name = 'Name is required'
    }
    if (!data.description.trim()) {
      newFieldErrors.description = 'Description is required'
    }
    if (!data.defaultModel.trim()) {
      newFieldErrors.defaultModel = 'Default model is required'
    }

    if (Object.keys(newFieldErrors).length > 0) {
      setFieldErrors(newFieldErrors)
      setIsSubmitting(false)
      return
    }

    try {
      const result = await createCharacter(getToken(), {
        name: data.name,
        description: data.description,
        alternateNames: alternateNames(),
        tags: tags(),
        defaultModel: data.defaultModel,
        isPublic: data.isPublic
      })

      if (result.errors && result.errors.length > 0) {
        setErrors(result.errors)
      } else if (result.character) {
        // Success - reset form and close modal
        setFormData({
          name: '',
          description: '',
          defaultModel: availableModels()[0] || 'Llama 3.2',
          isPublic: false
        })
        setAlternateNames([])
        setTags([])
        setNewAlternateName('')
        setNewTag('')
        setFieldErrors({})
        props.onCharacterCreated?.(result.character)
        props.onClose()
      }
    } catch (err) {
      console.error('Failed to create character:', err)
      setErrors(['Failed to create character. Please try again.'])
    } finally {
      setIsSubmitting(false)
    }
  }

  const updateField = (field: string, value: string | boolean) => {
    setFormData(prev => ({ ...prev, [field]: value }))
  }

  // Check if form is valid for submit button enablement
  const isFormValid = createMemo(() => {
    const data = formData()
    return data.name.trim() && data.description.trim() && data.defaultModel.trim()
  })

  const addAlternateName = () => {
    const name = newAlternateName().trim()
    if (name && !alternateNames().includes(name)) {
      setAlternateNames(prev => [...prev, name])
      setNewAlternateName('')
    }
  }

  const removeAlternateName = (index: number) => {
    setAlternateNames(prev => prev.filter((_, i) => i !== index))
  }

  const addTag = () => {
    const tag = newTag().trim()
    if (tag && !tags().includes(tag)) {
      setTags(prev => [...prev, tag])
      setNewTag('')
    }
  }

  const removeTag = (index: number) => {
    setTags(prev => prev.filter((_, i) => i !== index))
  }

  return (
    <Show when={props.isOpen}>
      <div class="modal-overlay" onClick={props.onClose}>
        <div class="modal-content" onClick={(e) => e.stopPropagation()}>
          <div class="modal-header">
            <h2 class="modal-title">Create New Character</h2>
            <button
              class="modal-close-button"
              onClick={props.onClose}
              type="button"
              aria-label="Close modal"
            >
              ✕
            </button>
          </div>

          <Show when={errors().length > 0}>
            <div class="modal-errors">
              <For each={errors()}>
                {(error) => <p class="modal-error">{error}</p>}
              </For>
            </div>
          </Show>

          <form class="modal-form" onSubmit={handleSubmit} noValidate role="form">
            <div class="form-group">
              <label class="form-label" for="character-name">
                Name *
              </label>
              <input
                id="character-name"
                type="text"
                class={`form-input ${fieldErrors().name ? 'form-input-error' : ''}`}
                value={formData().name}
                onInput={(e) => updateField('name', e.currentTarget.value)}
                placeholder="Enter character name"
              />
              <Show when={fieldErrors().name}>
                <p class="form-field-error">{fieldErrors().name}</p>
              </Show>
            </div>

            <div class="form-group">
              <label class="form-label" for="character-description">
                Description *
              </label>
              <textarea
                id="character-description"
                class={`form-textarea ${fieldErrors().description ? 'form-textarea-error' : ''}`}
                value={formData().description}
                onInput={(e) => updateField('description', e.currentTarget.value)}
                placeholder="Describe the character's personality, background, and traits"
                rows={4}
              />
              <Show when={fieldErrors().description}>
                <p class="form-field-error">{fieldErrors().description}</p>
              </Show>
            </div>

            <div class="form-group">
              <label class="form-label">
                Alternate Names
              </label>
              <div class="form-array-input">
                <input
                  type="text"
                  class="form-input"
                  value={newAlternateName()}
                  onInput={(e) => setNewAlternateName(e.currentTarget.value)}
                  placeholder="Enter alternate name"
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault()
                      addAlternateName()
                    }
                  }}
                />
                <button
                  type="button"
                  class="btn btn-secondary btn-add"
                  onClick={addAlternateName}
                  disabled={!newAlternateName().trim()}
                  aria-label="Add alternate name"
                >
                  +
                </button>
              </div>
              <Show when={alternateNames().length > 0}>
                <div class="form-array-list" data-testid="alternate-names-list">
                  <For each={alternateNames()}>
                    {(name, index) => (
                      <div class="form-array-item">
                        <span class="form-array-item-text">{name}</span>
                        <button
                          type="button"
                          class="btn btn-remove"
                          onClick={() => removeAlternateName(index())}
                          aria-label={`Remove ${name}`}
                        >
                          ×
                        </button>
                      </div>
                    )}
                  </For>
                </div>
              </Show>
              <p class="form-help">Add alternate names for this character</p>
            </div>

            <div class="form-group">
              <label class="form-label">
                Tags
              </label>
              <div class="form-array-input">
                <input
                  type="text"
                  class="form-input"
                  value={newTag()}
                  onInput={(e) => setNewTag(e.currentTarget.value)}
                  placeholder="Enter tag"
                  onKeyPress={(e) => {
                    if (e.key === 'Enter') {
                      e.preventDefault()
                      addTag()
                    }
                  }}
                />
                <button
                  type="button"
                  class="btn btn-secondary btn-add"
                  onClick={addTag}
                  disabled={!newTag().trim()}
                  aria-label="Add tag"
                >
                  +
                </button>
              </div>
              <Show when={tags().length > 0}>
                <div class="form-array-list" data-testid="tags-list">
                  <For each={tags()}>
                    {(tag, index) => (
                      <div class="form-array-item">
                        <span class="form-array-item-text">{tag}</span>
                        <button
                          type="button"
                          class="btn btn-remove"
                          onClick={() => removeTag(index())}
                          aria-label={`Remove ${tag}`}
                        >
                          ×
                        </button>
                      </div>
                    )}
                  </For>
                </div>
              </Show>
              <p class="form-help">Add tags to categorize this character (e.g., fantasy, warrior, noble)</p>
            </div>

            <div class="form-group">
              <label class="form-label" for="character-model">
                Default Model *
              </label>
              <select
                id="character-model"
                class={`form-select ${fieldErrors().defaultModel ? 'form-select-error' : ''}`}
                value={formData().defaultModel}
                onChange={(e) => updateField('defaultModel', e.currentTarget.value)}
              >
                <For each={availableModels()}>
                  {(model) => (
                    <option value={model}>{model}</option>
                  )}
                </For>
              </select>
              <Show when={fieldErrors().defaultModel}>
                <p class="form-field-error">{fieldErrors().defaultModel}</p>
              </Show>
            </div>

            <div class="form-group">
              <label class="form-checkbox-wrapper">
                <input
                  type="checkbox"
                  class="form-checkbox"
                  checked={formData().isPublic}
                  onChange={(e) => updateField('isPublic', e.currentTarget.checked)}
                />
                <span class="form-checkbox-label">Make this character public</span>
              </label>
              <p class="form-help">Public characters can be used by other users</p>
            </div>

            <div class="modal-actions">
              <button
                type="button"
                class="btn btn-secondary"
                onClick={props.onClose}
                disabled={isSubmitting()}
              >
                Cancel
              </button>
              <button
                type="submit"
                class="btn btn-primary"
                disabled={isSubmitting() || !isFormValid()}
              >
                {isSubmitting() ? 'Creating...' : 'Create Character'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Show>
  )
}

export default CreateCharacterModal
