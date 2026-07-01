
## Handling State in React Native

As React Native applications grow in complexity, managing application state becomes crucial. Simply relying on local component state (`useState`, `useReducer`) often leads to challenges like:

1.  **Prop Drilling:** Passing data down through many intermediate components that don't actually need the data themselves.
2.  **State Synchronization:** Keeping state consistent across different, unrelated parts of the application (e.g., user authentication status affecting both the header and a profile screen).
3.  **Complex State Logic:** Managing intricate state transitions, side effects (like API calls), and dependencies between different pieces of state.

Global state management libraries help address these issues by providing a centralized place to store and update application state, making it accessible from anywhere in the component tree.

We'll explore three popular approaches:

1.  **React Context API:** Built into React.
2.  **Redux:** The long-standing, predictable state container.
3.  **Zustand:** A modern, minimalist, hook-based alternative.

---

### 1. React Context API

*   **Concept:** Provides a way to pass data through the component tree without having to pass props down manually at every level. It's designed primarily for sharing data that can be considered "global" for a tree of React components, like the current authenticated user, theme, or preferred language.
*   **Core Primitives:**
    *   `React.createContext()`: Creates a Context object.
    *   `<MyContext.Provider value={...}>`: A component that wraps part of your tree. Any component within this provider can subscribe to context changes. The `value` prop holds the data being shared.
    *   `useContext(MyContext)`: A hook used in functional components to read the current context value from the nearest matching Provider above it in the tree.
*   **Pros:**
    *   Built directly into React (no extra library needed).
    *   Relatively simple setup for basic global state.
    *   Good for low-frequency updates (themes, user auth status).
*   **Cons:**
    *   **Performance:** When the `value` prop of the Provider changes, *all* components consuming that context using `useContext` will re-render by default, even if they only care about a small part of the `value` object that didn't change. This requires careful optimization using techniques like `React.memo`, splitting contexts, or using `useMemo` for the provider value.
    *   Can become unwieldy if managing many different pieces of state – you might end up with multiple nested providers.
    *   Doesn't inherently provide structure for managing complex state logic or side effects.

---

### 2. Redux (with React Redux)

*   **Concept:** A predictable state container based on Flux principles. It enforces a strict unidirectional data flow. State is immutable, and changes happen by dispatching "actions" (plain objects describing what happened) which are processed by "reducers" (pure functions that calculate the next state).
*   **Core Primitives:**
    *   **Store:** A single object holding the entire application state tree. The single source of truth.
    *   **Actions:** Plain JavaScript objects describing an intention to change state (e.g., `{ type: 'INCREMENT_COUNTER' }`, `{ type: 'FETCH_USER_SUCCESS', payload: userData }`).
    *   **Reducers:** Pure functions `(previousState, action) => newState` that take the current state and an action, and return the next state. They must be pure (no side effects, same input always yields same output).
    *   **Dispatch:** A function (`store.dispatch(action)`) used to send actions to the store. This is the *only* way to trigger a state change.
    *   **Selectors:** Functions used to extract specific pieces of data from the store state (often used with `useSelector` hook from `react-redux`).
    *   **Middleware:** Functions that intercept dispatched actions before they reach the reducer. Used for logging, handling asynchronous operations (like API calls via Redux Thunk or Redux Saga), etc.
*   **Pros:**
    *   **Predictability:** Strict rules make state changes easy to follow and debug.
    *   **Testability:** Pure reducers are easy to unit test.
    *   **Scalability:** Well-suited for large, complex applications with many developers.
    *   **Excellent DevTools:** Time-travel debugging, action logging, state inspection.
    *   **Large Ecosystem:** Mature library with extensive community support and middleware options.
*   **Cons:**
    *   **Boilerplate:** Can involve writing a lot of repetitive code (actions, action creators, reducers, selectors). Libraries like Redux Toolkit significantly reduce this.
    *   **Learning Curve:** Can be more complex to grasp initially compared to Context or Zustand.
    *   Can feel like overkill for simpler applications.

---

### 3. Zustand (Focus Area)

*   **Concept:** A small, fast, and scalable state management solution using simplified flux principles. It leverages React hooks and is designed to be minimalist and unopinionated, offering global state management often with much less boilerplate than Redux. State lives *outside* of React components.
*   **Core Primitives:**
    *   **`create(initializer)`:** The primary function. You pass it a function that receives `set` and `get` arguments and returns the initial state object. This object can contain both state values *and* functions (actions) that modify the state. `create` returns a custom hook.
    *   **The Hook:** The hook returned by `create` is used directly in components to access state.
    *   **`set(partialState | (state) => partialState)`:** Function provided to your initializer and actions. Used to merge updates into the state.
    *   **`get()`:** Function provided to your initializer and actions. Used to access the current state values (useful within actions).
    *   **Selectors:** When using the hook, you provide a selector function `state => state.pieceOfState`. The component will *only* re-render if the *return value* of this selector changes. This is automatic performance optimization.

*   **Installation:**
    ```bash
    npm install zustand
    # or
    yarn add zustand
    ```

*   **Pros:**
    *   **Minimal Boilerplate:** Significantly less setup code compared to Redux. Often feels like a global `useState`.
    *   **Easy to Learn:** Simple API, leverages familiar hook patterns.
    *   **Excellent Performance:** Automatic state-change detection based on selectors prevents unnecessary re-renders out-of-the-box.
    *   **Unopinionated:** Flexible structure for organizing state and actions.
    *   **Decoupled:** State logic lives outside components.
    *   **React Independent:** Can be used outside React.
    *   **Integrates Middleware:** Supports Redux DevTools, persistence, and other middleware easily.

*   **Cons:**
    *   Less opinionated means team discipline is needed for consistency in large projects.
    *   Smaller (but rapidly growing) ecosystem compared to Redux.
    *   DevTools integration requires explicit setup (though it's straightforward).

**Zustand Examples:**

**Example 1: Simple Counter Store**

```javascript
// store/counterStore.js
import { create } from 'zustand';

// 1. Create the store using the `create` function
const useCounterStore = create((set) => ({
  // State variable
  count: 0,

  // Action: function defined directly in the store
  increment: () => set((state) => ({ count: state.count + 1 })),

  // Action: another function
  decrement: () => set((state) => ({ count: state.count - 1 })),

  // Action: reset count
  reset: () => set({ count: 0 }), // Can also pass an object directly to merge
}));

export default useCounterStore;


// components/CounterDisplay.js
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import useCounterStore from '../store/counterStore';

const CounterDisplay = () => {
  // 2. Use the hook and provide a selector function
  // This component ONLY re-renders if `state.count` changes.
  const count = useCounterStore((state) => state.count);

  console.log('CounterDisplay rendered');

  return (
    <View style={styles.container}>
      <Text style={styles.text}>Count: {count}</Text>
    </View>
  );
};

// components/CounterControls.js
import React from 'react';
import { View, Button } from 'react-native';
import useCounterStore from '../store/counterStore';

const CounterControls = () => {
  // 3. Select multiple items (actions in this case)
  // If you select an object, it re-renders if the object *identity* changes.
  // It's often better to select actions individually or via shallow comparison.
  // const { increment, decrement, reset } = useCounterStore(state => ({
  //   increment: state.increment,
  //   decrement: state.decrement,
  //   reset: state.reset,
  // }));

  // Optimized way: Select only the actions needed.
  // Actions usually don't change, so this won't cause re-renders often.
  const increment = useCounterStore((state) => state.increment);
  const decrement = useCounterStore((state) => state.decrement);
  const reset = useCounterStore((state) => state.reset);

  console.log('CounterControls rendered');

  return (
    <View>
      <Button title="Increment" onPress={increment} />
      <Button title="Decrement" onPress={decrement} />
      <Button title="Reset" onPress={reset} />
    </View>
  );
};

// styles (simplified)
const styles = StyleSheet.create({
  container: { marginVertical: 10 },
  text: { fontSize: 18 },
});

export { CounterDisplay, CounterControls };
```

**Example 2: Async Action (Fetching User Data)**

```javascript
// store/userStore.js
import { create } from 'zustand';
import { fetchUserDataApi } from '../api/user'; // Assume this returns a Promise

const useUserStore = create((set, get) => ({
  // State variables
  user: null,
  isLoading: false,
  error: null,

  // Async Action
  fetchUser: async (userId) => {
    // Optional: Access current state before fetching
    // console.log('Current user state:', get().user);

    // Set loading state immediately
    set({ isLoading: true, error: null });

    try {
      const userData = await fetchUserDataApi(userId);
      // Update state on success
      set({ user: userData, isLoading: false });
    } catch (err) {
      // Update state on error
      set({ error: err.message || 'Failed to fetch user', isLoading: false, user: null });
    }
  },

  // Simple action to clear user data
  clearUser: () => set({ user: null, error: null }),
}));

export default useUserStore;


// components/UserProfile.js
import React, { useEffect } from 'react';
import { View, Text, Button, ActivityIndicator, StyleSheet } from 'react-native';
import useUserStore from '../store/userStore';
import { shallow } from 'zustand/shallow'; // Import shallow

const UserProfile = ({ userId }) => {
  // Select multiple state pieces. Use `shallow` for optimization.
  // `shallow` compares object properties one level deep.
  // The component re-renders only if isLoading, user, or error *value* changes.
  const { user, isLoading, error, fetchUser } = useUserStore(
    (state) => ({
      user: state.user,
      isLoading: state.isLoading,
      error: state.error,
      fetchUser: state.fetchUser, // Action
    }),
    shallow // Use shallow comparison
  );

  // Fetch user when component mounts or userId changes
  useEffect(() => {
    if (userId) {
      fetchUser(userId);
    }
  }, [userId, fetchUser]); // Include fetchUser in dependency array

  return (
    <View style={styles.container}>
      <Text style={styles.title}>User Profile</Text>
      {isLoading && <ActivityIndicator size="large" color="#0000ff" />}
      {error && <Text style={styles.errorText}>Error: {error}</Text>}
      {user && !isLoading && (
        <View>
          <Text>Name: {user.name}</Text>
          <Text>Email: {user.email}</Text>
        </View>
      )}
      {!user && !isLoading && !error && <Text>No user data loaded.</Text>}
       <Button title={`Fetch User ${userId + 1}`} onPress={() => fetchUser(userId + 1)} />
    </View>
  );
};

// styles (simplified)
const styles = StyleSheet.create({
  container: { padding: 20, borderWidth: 1, margin: 10 },
  title: { fontSize: 20, marginBottom: 10 },
  errorText: { color: 'red' },
});

export default UserProfile;

```

**Key Zustand Patterns:**

*   **Selectors are Key:** Always use selectors (`state => state.value`) to pick only the state needed. This is Zustand's core performance feature.
*   **Shallow Compare for Objects:** When selecting multiple values into an object `useStore(state => ({ a: state.a, b: state.b }))`, use the `shallow` equality function `useStore(selector, shallow)` from `zustand/shallow` to prevent re-renders if the *values* haven't changed but the object reference has.
*   **Actions Inside Store:** Define actions (functions that call `set` or `get`) directly within the `create` initializer. This co-locates state and the logic that changes it.
*   **Async Actions:** Just define `async` functions within `create` and call `set` at different stages (start loading, success, error).
*   **`get()` for Access:** Use `get()` inside actions if you need to read the current state to compute the next state.

---

### 4. Comparison Summary

| Feature         | Context API                  | Redux (Toolkit)                | Zustand                      |
| :-------------- | :--------------------------- | :----------------------------- | :--------------------------- |
| **Boilerplate** | Low                          | Medium (with Toolkit)          | Very Low                     |
| **Learning Curve**| Low                          | Medium/High                    | Low                          |
| **Performance** | Needs manual optimization    | Good (optimized selectors)     | Excellent (auto optimization)|
| **DevTools**    | Basic React DevTools         | Excellent (Time travel, etc.)  | Good (via middleware)        |
| **Ecosystem**   | N/A (Built-in)               | Very Large                     | Growing                      |
| **Flexibility** | Low (Primarily prop drilling)| Medium (Structured)            | High (Unopinionated)         |
| **Core Concept**| Dependency Injection via Tree| Predictable State Container    | Hook-based Global State      |

---

### 5. When to Choose What?

*   **Context API:** Best for simple, low-frequency global data like themes, user authentication status, locale settings. Use it when prop drilling becomes annoying for static or rarely changing values. Be cautious with frequently updating values due to potential performance hits.
*   **Zustand:** A great default choice for many React Native applications. It hits a sweet spot between simplicity and power. Excellent if you find yourself overusing `useState` and prop drilling, need good performance without manual optimization, and prefer a hook-based, less verbose approach than Redux.
*   **Redux:** Suitable for very large, complex applications where strict structure, predictability, extensive middleware capabilities, and powerful debugging tools (like time travel) are paramount. Also a good choice if the team is already heavily invested in and comfortable with the Redux ecosystem. Consider using Redux Toolkit to reduce boilerplate.


---

# Folder Structure

**Key Idea:** Zustand stores are typically defined in separate files and imported via the custom hook they expose. This makes them quite flexible regarding where they live.

---

**Option 1: Centralized `stores` Directory (Good for Small to Medium Apps)**

This is a very common and straightforward approach, especially when starting. All your state logic resides in a dedicated top-level directory.

```
my-rn-app/
├── src/
│   ├── stores/                 <-- Central directory for all Zustand stores
│   │   ├── useAuthStore.js     <-- Authentication state logic
│   │   ├── useCartStore.js     <-- Shopping cart state logic
│   │   ├── useSettingsStore.js <-- App settings state logic
│   │   └── index.js            <-- (Optional) Re-export stores for cleaner imports
│   │
│   ├── components/             <-- Reusable UI components
│   │   ├── Button.js
│   │   └── Header.js           <-- Might consume useAuthStore
│   │
│   ├── screens/                <-- Application screens (views)
│   │   ├── LoginScreen.js      <-- Consumes useAuthStore
│   │   ├── HomeScreen.js
│   │   ├── CartScreen.js       <-- Consumes useCartStore
│   │   └── SettingsScreen.js   <-- Consumes useSettingsStore
│   │
│   ├── navigation/             <-- Navigation setup (React Navigation, etc.)
│   │   └── AppNavigator.js
│   │
│   ├── api/                    <-- API fetching logic
│   │   └── index.js
│   │
│   └── App.js                  <-- Main application entry point
│
├── android/
├── ios/
├── index.js                    <-- React Native entry point
└── package.json
```

*   **Pros:** Simple, easy to understand, all state logic is in one predictable place.
*   **Cons:** For very large apps, this directory could become crowded. Might slightly decouple state logic from the features that primarily use it.
*   **(Optional `stores/index.js`):**
    ```javascript
    // src/stores/index.js
    export { default as useAuthStore } from './useAuthStore';
    export { default as useCartStore } from './useCartStore';
    export { default as useSettingsStore } from './useSettingsStore';
    // Allows importing like: import { useAuthStore } from '../stores';
    ```

---

**Option 2: Feature-Based Co-location (Good for Medium to Large Apps)**

In this approach, state logic lives alongside the feature or domain it most closely relates to. This promotes modularity and makes it easier for teams to work on different features independently.

```
my-rn-app/
├── src/
│   ├── features/                 <-- Top-level directory for features/domains
│   │   ├── Authentication/
│   │   │   ├── components/
│   │   │   │   └── LoginForm.js
│   │   │   ├── screens/
│   │   │   │   └── LoginScreen.js
│   │   │   ├── store/            <-- Store specific to this feature
│   │   │   │   └── useAuthStore.js
│   │   │   └── api/
│   │   │       └── authApi.js
│   │   │
│   │   ├── Cart/
│   │   │   ├── components/
│   │   │   │   └── CartItem.js
│   │   │   ├── screens/
│   │   │   │   └── CartScreen.js
│   │   │   └── store/
│   │   │       └── useCartStore.js
│   │   │
│   │   └── Products/
│   │       ├── components/
│   │       │   └── ProductCard.js
│   │       ├── screens/
│   │       │   └── ProductListScreen.js
│   │       └── api/
│   │           └── productsApi.js
│   │           // (Maybe no specific store needed here if state is local or fetched on demand)
│   │
│   ├── components/               <-- SHARED/Common reusable components
│   │   ├── Button.js
│   │   └── LoadingIndicator.js
│   │
│   ├── navigation/
│   │   └── AppNavigator.js
│   │
│   ├── shared/                   <-- Shared utilities, hooks, types, etc.
│   │   ├── hooks/
│   │   ├── types/
│   │   └── stores/               <-- Optional: For truly global, cross-feature stores
│   │       └── useThemeStore.js  <-- e.g., UI theme store
│   │
│   └── App.js
│
├── android/
├── ios/
├── index.js
└── package.json
```

*   **Pros:** Highly modular, scales well, keeps related logic together, good for team collaboration.
*   **Cons:** Can involve slightly deeper nesting, requires deciding which feature "owns" a piece of state (sometimes state spans multiple features). Needs a place for truly shared/global state (like the `shared/stores/` example).
*   **Naming:** Instead of `store/`, you might just name the file directly within the feature, e.g., `Authentication/authStore.js`. Consistency is key.

---

**Choosing a Structure:**

*   **Start Simple:** If unsure, begin with the centralized `stores` directory (Option 1). It's easy to refactor later if needed.
*   **Consider Team Size & App Complexity:** For larger projects or multiple teams, the feature-based approach (Option 2) often provides better organization and reduces potential conflicts.
*   **Consistency is Crucial:** Whichever structure you choose, stick to it consistently throughout the project.

Both structures work well with Zustand because its hook-based nature makes importing straightforward regardless of the file location. The choice primarily impacts project organization and maintainability.