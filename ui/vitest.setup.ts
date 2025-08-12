// Setup file for vitest to configure Solid.js JSX runtime
import '@testing-library/jest-dom';
import { vi } from 'vitest';
import { createRoot } from 'solid-js';

// Mock global objects if needed
vi.stubGlobal('fetch', vi.fn());

// Ensure Solid.js JSX runtime is initialized
createRoot(() => {});
