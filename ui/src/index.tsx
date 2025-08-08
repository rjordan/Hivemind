/* @refresh reload */
import { render } from 'solid-js/web';
import { Router, Route } from '@solidjs/router';

import App from './App';
import TopBar from './Topbar';
import Conversations from './Converstations';

const root = document.getElementById('root');

if (import.meta.env.DEV && !(root instanceof HTMLElement)) {
  throw new Error(
    'Root element not found. Did you forget to add it to your index.html? Or maybe the id attribute got misspelled?',
  );
}

render(() => (
  <div class="min-h-screen bg-gray-100">
    <TopBar />
    <Router>
      <Route path="/" component={App} />
      <Route path="/conversations" component={Conversations} />
    </Router>
  </div>
), root!);
