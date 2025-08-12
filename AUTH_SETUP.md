# Authentication Setup

This application uses GitHub OAuth for authentication. Here's how to set it up:

## 1. Create a GitHub OAuth App

1. Go to [GitHub Settings > Developer settings > OAuth Apps](https://github.com/settings/applications/new)
2. Click "New OAuth App"
3. Fill in the details:
   - **Application name**: Hivemind (or your preferred name)
   - **Homepage URL**: `http://localhost:5173` (or your frontend URL)
   - **Authorization callback URL**: `http://localhost:5173/auth/callback`
4. Click "Register application"
5. Note down the **Client ID** and generate a **Client Secret**

## 2. Configure Environment Variables

### Backend (.env)
Copy `.env.example` to `.env` and fill in:
```
GITHUB_CLIENT_ID=your_github_client_id_here
GITHUB_CLIENT_SECRET=your_github_client_secret_here
```

### Frontend (ui/.env)
Copy `ui/.env.example` to `ui/.env` and fill in:
```
VITE_GITHUB_CLIENT_ID=your_github_client_id_here
```

## 3. Run the Application

1. Start the Rails backend:
   ```bash
   bundle install
   rails db:migrate
   rails server
   ```

2. Start the frontend:
   ```bash
   cd ui
   npm install
   npm run dev
   ```

## 4. Authentication Flow

1. User clicks "Sign in with GitHub" on the login page
2. User is redirected to GitHub for authorization
3. GitHub redirects back to `/auth/callback` with an authorization code
4. Frontend exchanges the code for a JWT token via the backend
5. JWT token is stored in localStorage and used for API authentication
6. All protected routes require a valid JWT token

## Security Notes

- JWT tokens expire after 30 days
- The GitHub Client Secret is only used on the backend
- The Client ID can be safely exposed to the frontend
- Always use HTTPS in production
