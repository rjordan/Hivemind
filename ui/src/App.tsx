import './App.scss';

import { Component, ErrorBoundary, Suspense } from 'solid-js';

import TopBar from './Topbar';
import Home from "./Home";
import Conversations from './Converstations';
import { Router, Route } from '@solidjs/router';

const App: Component = () => {

  return (
    <main class="min-h-screen bg-gray-100 hivemind-app">
      <TopBar />
      <ErrorBoundary fallback={<div>Something went wrong</div>}>
        <Suspense fallback={<div>Loading...</div>}>
          <Router>
            <Route path="/" component={Home} />
            <Route path="/conversations" component={Conversations} />
          </Router>
        </Suspense>
      </ErrorBoundary>
    </main>
  );
};

export default App;
