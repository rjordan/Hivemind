import { createSignal } from "solid-js";

const TopBar = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = createSignal(false);

  const toggleMobileMenu = () => {
    setIsMobileMenuOpen(!isMobileMenuOpen());
  };

  const closeMobileMenu = () => {
    setIsMobileMenuOpen(false);
  };

  return (
    <nav class="topbar">
      <div class="topbar__container">
        <a href="/" class="topbar__brand">🧠 Hivemind</a>

        <div class="topbar__nav">
          <a href="/conversations" class="topbar__nav-link topbar__nav-link--active">Conversations</a>
          <a href="#" class="topbar__nav-link">Characters</a>
          <a href="#" class="topbar__nav-link">Profiles</a>
          <div class="topbar__dropdown">
            <button class="topbar__nav-link topbar__dropdown-button">
              Settings
              <svg class="topbar__dropdown-icon" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            <div class="topbar__dropdown-menu">
              <a href="#" class="topbar__dropdown-item">👤 Profile</a>
              <a href="#" class="topbar__dropdown-item">🚪 Sign Out</a>
            </div>
          </div>
        </div>

        <button
          type="button"
          onClick={toggleMobileMenu}
          class="topbar__mobile-toggle"
          aria-expanded={isMobileMenuOpen() ? 'true' : 'false'}
        >
          <span class="sr-only">Open main menu</span>
          {!isMobileMenuOpen() ? (
            <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          ) : (
            <svg class="h-6 w-6" stroke="currentColor" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          )}
        </button>
      </div>

      {/* Mobile menu */}
      <div class={`topbar__mobile-menu ${isMobileMenuOpen() ? 'topbar__mobile-menu--open' : ''}`}>
        <div class="topbar__mobile-nav">
          <a href="/conversations" class="topbar__mobile-nav-link topbar__mobile-nav-link--active" onClick={closeMobileMenu}>💬 Conversations</a>
          <a href="#" class="topbar__mobile-nav-link" onClick={closeMobileMenu}>👥 Characters</a>
          <a href="#" class="topbar__mobile-nav-link" onClick={closeMobileMenu}>📋 Profiles</a>
          <a href="#" class="topbar__mobile-nav-link" onClick={closeMobileMenu}>⚙️ Settings</a>
          <a href="#" class="topbar__mobile-nav-link" onClick={closeMobileMenu}>👤 Profile</a>
          <a href="#" class="topbar__mobile-nav-link" onClick={closeMobileMenu}>🚪 Sign Out</a>
        </div>
      </div>
    </nav>
  );
};

export default TopBar;
