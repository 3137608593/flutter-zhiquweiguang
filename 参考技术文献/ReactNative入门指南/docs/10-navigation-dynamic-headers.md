
 You often want the header title to reflect data loaded within the screen itself (like a user's name, a product title, etc.) rather than being statically defined in the navigator setup.

You achieve this using the **`navigation.setOptions`** method *inside* your screen component.

Here's how it works:

1.  **Access `navigation` Prop:** Your screen component receives the `navigation` prop, just like for navigating.
2.  **Call `setOptions`:** Inside your component (often within a `useEffect` hook), you call `navigation.setOptions()` and pass an object containing the options you want to update. In this case, you'll update the `title`.

**Example Scenario:**

Let's say you have a `UserProfileScreen` that receives a `userId` via route params, fetches the user's data, and then wants to display the user's name in the header.

```javascript
// UserProfileScreen.js
import React, { useState, useEffect } from 'react';
import { View, Text, ActivityIndicator } from 'react-native';
import { getUserData } from './api'; // Assume this fetches user data

function UserProfileScreen({ route, navigation }) {
  // Get userId passed during navigation
  const { userId } = route.params;

  // State to hold user data and loading status
  const [user, setUser] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  // Effect to fetch data and set the header title
  useEffect(() => {
    const fetchUser = async () => {
      try {
        setIsLoading(true);
        const userData = await getUserData(userId); // Fetch data based on userId
        setUser(userData);

        // *** THIS IS THE KEY PART ***
        // Once data is fetched, update the header title
        if (userData && userData.name) {
          navigation.setOptions({ title: userData.name }); // Set title dynamically
        } else {
          navigation.setOptions({ title: 'User Profile' }); // Fallback title
        }
        // ***************************

      } catch (error) {
        console.error("Failed to fetch user data:", error);
        navigation.setOptions({ title: 'Error Loading Profile' }); // Error state title
      } finally {
        setIsLoading(false);
      }
    };

    fetchUser();

    // Dependency array: re-run effect if navigation or userId changes
    // Although userId typically won't change for the *same screen instance*,
    // including it is good practice if the component could potentially be
    // reused with different params via navigation.push or replace.
  }, [navigation, userId]);

  // --- Screen Content ---
  if (isLoading) {
    return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (!user) {
     return (
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <Text>User not found.</Text>
      </View>
    );
  }

  return (
    <View style={{ flex: 1, padding: 20 }}>
      <Text style={{ fontSize: 18 }}>User ID: {user.id}</Text>
      <Text style={{ fontSize: 18 }}>Email: {user.email}</Text>
      {/* Display other user details */}
    </View>
  );
}

export default UserProfileScreen;
```

**Explanation:**

1.  **`useEffect` Hook:** We use `useEffect` to perform the data fetching side effect *after* the component renders.
2.  **Fetch Data:** Inside the effect, we call our hypothetical `getUserData` function.
3.  **`navigation.setOptions({ title: userData.name })`:** *After* successfully fetching the `userData`, we call `navigation.setOptions`. We pass an object specifying only the option we want to change (`title`) and set its value to the fetched `userData.name`.
4.  **Dependency Array `[navigation, userId]`:** This tells React to re-run the `useEffect` hook if either the `navigation` object or the `userId` parameter changes. This ensures that if the user somehow navigates to the *same* screen component instance but with a different `userId` (less common with `navigate`, more possible with `push`), the data and title will refresh.
5.  **Loading/Error States:** We handle loading and potential errors, setting appropriate fallback titles using `navigation.setOptions` in those cases too.

**Why use `useEffect`?**

*   **Data Fetching:** You usually need to fetch data asynchronously. `useEffect` is the standard place to handle side effects like data fetching in functional components.
*   **Timing:** You can only call `navigation.setOptions` *after* the component has mounted and the `navigation` prop is available. `useEffect` guarantees this. You cannot call it directly in the component body during the initial render.

**Initial Title (Optional but Recommended):**

You might still want to set an initial, static title in the navigator configuration for a better perceived performance (avoids the title potentially flickering from a default to the dynamic one):

```javascript
// In your Navigator setup
<Stack.Screen
  name="UserProfile"
  component={UserProfileScreen}
  options={{ title: 'Loading Profile...' }} // Initial static title
/>
```

Then, the `navigation.setOptions` call inside `UserProfileScreen` will override this initial title once the data is ready.

In summary, `navigation.setOptions` is the standard and flexible way for a screen component to dynamically control its appearance (like the header title) within the navigator, often based on its own state or data.