---
publishDate: "2023-12-03"
toc: true
title: Fiber Tree and Virtual DOM in React
image: /images/fiber-tree.jpg
tags: ["React", "Virtual DOM", "Fiber Tree", "Reconciliation"]

excerpt:
---

In React, when a component receives new props, it triggers a re-rendering process to update the UI. This update mechanism is tightly coupled with React's **Virtual DOM** and **Fiber Tree** — two fundamental components of its rendering architecture. To fully grasp what happens behind the scenes, we need to break down how React optimizes this re-rendering through its Virtual DOM and Fiber architecture.

Let’s dive into how the two interact and why they are essential to React's performance.

## The Virtual DOM: A Brief Overview

The Virtual DOM is a lightweight representation of the actual DOM (Document Object Model). It is a virtual copy that React uses to efficiently determine which parts of the UI need to be updated without directly interacting with the browser’s DOM, which is slower.

Key aspects of the Virtual DOM:

1. **Abstraction**: The Virtual DOM abstracts away direct manipulation of the real DOM, making the process faster and more efficient.
2. **Comparison (Diffing Algorithm)**: When new props or state changes are detected, React creates a new Virtual DOM tree and compares it with the previous one to find the minimal set of changes.
3. **Batching Updates**: React batches multiple updates into a single operation to reduce the number of costly interactions with the real DOM.

In essence, React maintains two copies of the Virtual DOM: the previous tree and the updated tree. The comparison between these two versions allows React to update only the parts of the UI that need to change, rather than re-rendering the entire application.

## The Fiber Tree: React’s Efficient Reconciliation Engine

The Fiber Tree is React's underlying mechanism to handle updates efficiently. Introduced in React 16, Fiber is a reimplementation of React’s reconciliation algorithm, allowing React to break up the rendering work into incremental, manageable chunks.

#### Fiber's Key Characteristics:

1. **Incremental Rendering**: React Fiber allows updates to be broken into small units of work, which can be paused and resumed to avoid blocking the main thread for too long. This ensures that the UI remains responsive even during large updates.

2. **Prioritization of Updates**: Fiber introduces the concept of update prioritization. Not all updates are equally important (e.g., user interactions like typing are more critical than background data fetching). React assigns priorities to updates and ensures that higher-priority work is handled first.

3. **Tree Structure**: Like the Virtual DOM, the Fiber Tree is also a tree data structure where each component is represented as a fiber node. Each node contains information about the component, its state, props, and references to its children and parent nodes.

## The Lifecycle of a React Update: From New Props to Fiber Reconciliation

1. **Receiving New Props**: When a React component receives new props, the first step is triggering the `render()` function of that component. React evaluates whether any changes are needed.

2. **Creation of a New Virtual DOM**: React builds a new Virtual DOM tree that represents the current state of the UI based on the new props.

3. **Fiber Reconciliation**:

   - React now uses the **Fiber Tree** to orchestrate the update. Fiber breaks the work into small, interruptible units to ensure smooth rendering.
   - The current Fiber Tree is compared against the new Virtual DOM tree. This process is called **reconciliation**. Each fiber node represents a component and its sub-tree.
   - **Diffing**: React compares the new virtual nodes with the old ones, identifying changes such as node updates, additions, or removals.

4. **Commit Phase**:
   - After reconciliation, React commits the necessary changes to the actual DOM. These changes are batched and only the minimal updates are applied, making this process fast and efficient.

## Fiber’s Role in Scheduling and Prioritization

One of Fiber’s most significant improvements is **time-slicing** and **scheduling**. In earlier versions of React, rendering updates were synchronous, which could block the main thread for extended periods, leading to UI jank. Fiber changes this by introducing **cooperative scheduling**.

1. **Time Slicing**: React can split rendering work into chunks and distribute them over multiple frames. This allows React to yield back control to the browser, giving it a chance to handle other tasks (like user input or animations).

2. **Update Prioritization**: Fiber tracks updates through a priority system. Critical tasks (like typing in a text input) are assigned higher priority than non-critical tasks (like updating a hidden component), allowing the app to remain responsive.

## How Virtual DOM and Fiber Tree Work Together

When React updates a component, it uses the Virtual DOM to represent the updated UI. The Fiber Tree is responsible for ensuring this process happens smoothly by managing the reconciliation of changes.

1. **Virtual DOM for Diffing**: The Virtual DOM helps identify what has changed between the current and the previous render. This comparison yields the **diff**, which tells React what changes need to be made to the actual DOM.

2. **Fiber for Reconciliation**: The Fiber Tree orchestrates how the updates are applied to the real DOM. By breaking the work into units, React can process these changes incrementally, ensuring responsiveness and prioritizing important tasks first.

## Key Benefits of Fiber and Virtual DOM

- **Improved Performance**: The Virtual DOM allows React to batch updates and minimize direct DOM manipulation, while Fiber ensures updates are efficiently processed without blocking the UI.

- **Smoother User Experience**: Fiber's time-slicing ensures React can handle even complex updates without freezing or slowing down the application.

- **Prioritization**: Fiber's scheduling mechanism prioritizes critical UI updates, allowing React apps to feel responsive, even under heavy loads.

React's Efficiency through Virtual DOM and Fiber Tree

Passing new props to a React component is just the beginning of a sophisticated rendering and reconciliation process. The Virtual DOM plays a key role in efficiently detecting changes, while the Fiber Tree ensures those changes are applied in a way that doesn’t block the main thread or cause sluggish behavior. Together, they enable React to maintain its high performance and responsive UI, even in large applications.

Understanding these underlying mechanisms gives developers a clearer picture of how React optimizes performance and handles updates under the hood, allowing them to build smoother and more efficient applications.
