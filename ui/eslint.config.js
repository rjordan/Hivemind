import js from '@eslint/js'
import typescript from '@typescript-eslint/eslint-plugin'
import typescriptParser from '@typescript-eslint/parser'

export default [
  js.configs.recommended,
  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      parser: typescriptParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: {
          jsx: true
        }
      },
      globals: {
        // Browser globals
        window: 'readonly',
        document: 'readonly',
        console: 'readonly',
        fetch: 'readonly',
        alert: 'readonly',
        localStorage: 'readonly',
        URLSearchParams: 'readonly',
        Event: 'readonly',
        HTMLElement: 'readonly',
        // Test globals
        global: 'readonly',
        // Vitest globals
        describe: 'readonly',
        it: 'readonly',
        expect: 'readonly',
        vi: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly'
      }
    },
    plugins: {
      '@typescript-eslint': typescript
    },
    rules: {
      // Semicolon rules - only require where necessary
      'semi': ['error', 'never'],

      // Basic TypeScript rules
      '@typescript-eslint/no-unused-vars': ['error', { 'argsIgnorePattern': '^_' }],
      '@typescript-eslint/no-explicit-any': 'warn',

      // Allow unused variables in specific cases
      'no-unused-vars': ['error', { 'argsIgnorePattern': '^_', 'varsIgnorePattern': '^_' }],

      // General formatting
      'quotes': ['error', 'single', { 'avoidEscape': true, 'allowTemplateLiterals': true }],
      'indent': ['error', 2],
      'no-trailing-spaces': 'error',
      'eol-last': 'error'
    }
  }
]
