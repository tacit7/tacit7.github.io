---
publishDate: "2021-09-14"
title: "Tailwind in Rails"
tags: [Rails, JavaScript, Tutorials]

toc: true
toc_label: 'Tailwind'
image: /images/tailwind.jpg
  # actions:
  #   - label: "Part 2"
  #     url: "/a-tailwind-tutorial-2"
excerpt: Tailwind CSS is a utility-first CSS framework for rapidly building modern websites without ever leaving your HTML. Let's see how we can use this CSS framework in Rails!
---

When building web applications, having a consistent and appealing design is essential. Tailwind CSS offers a unique and efficient approach to styling your web projects. Instead of writing traditional CSS, Tailwind provides utility-first classes that allow you to build custom designs without leaving your HTML.

### What is Tailwind CSS?

Tailwind CSS is a utility-first CSS framework that provides a wide array of classes to control layout, spacing, typography, colors, and more. Unlike traditional CSS frameworks that provide pre-designed components, Tailwind gives you the building blocks to create your own designs. This approach allows for more flexibility and customization.

### Key Features of Tailwind CSS

1. **Utility-First Approach**: Tailwind's utility-first classes make it easy to style elements directly in your HTML, reducing the need for writing custom CSS.
2. **Customization**: Tailwind is highly customizable. You can configure it to suit your project's needs using the `tailwind.config.js` file.
3. **Responsive Design**: Tailwind makes responsive design simple with its mobile-first approach. You can easily apply styles based on breakpoints.
4. **Built-in Dark Mode**: Tailwind supports dark mode out of the box, allowing you to easily create themes.
5. **JIT Mode**: The Just-In-Time (JIT) mode compiles your CSS on-demand, resulting in smaller file sizes and faster load times.

### Why Use Tailwind CSS?

- **Efficiency**: Quickly style your elements without switching between your HTML and CSS files.
- **Consistency**: Ensure a consistent design across your application with utility classes.
- **Flexibility**: Tailwind’s customization options allow you to tailor your styles to your specific needs.
- **Responsive**: Easily build responsive designs with built-in breakpoints.

## Getting Started with Tailwind CSS

### Create a New Rails Project

With a solid understanding of Tailwind CSS, let's dive into creating a new Ruby on Rails project. In this section, we'll set up a new Rails project and integrate Tailwind CSS.
### Setting Up Your Rails Project

To create a new Rails project with Tailwind CSS, we'll use the following command:

`rails new tailwind -a propshaft --javascript esbuild --css tailwind`

Let's break down what this command does:

- `rails new tailwind`: Creates a new Rails application named `tailwind`.
- `-a propshaft`: Specifies the use of [Propshaft]( https://tacit7.github.io/propshaft) for managing assets.
- `--javascript esbuild`: Configures the project to use [ESBuild]( https://tacit7.github.io/esbuild) for managing JavaScript.
- `--css tailwind`: Sets up Tailwind CSS for styling your application.

### Step-by-Step Guide

#### 1. Run the Command

Open your terminal and navigate to the directory where you want to create your new Rails project. Run the command mentioned above:

`rails new tailwind -a propshaft --javascript esbuild --css tailwind`

Rails will automatically install all necessary dependencies for you.

#### 2. Navigate to Your Project Directory

Once the project is created, navigate into the project directory:

`cd tailwind`

#### 3. Verify Tailwind CSS Integration

Rails automatically sets up Tailwind CSS for you. To verify the setup, open the `application.tailwind.css` file located in `app/assets/stylesheets/`. You should see the following Tailwind directives:

```js
@tailwind base;
@tailwind components;
@tailwind utilities;`
```

These lines ensure that Tailwind’s base, component, and utility styles are included in your project.

#### 4. Start the Rails Server

Start your Rails server to ensure everything is set up correctly:

`./bin/dev`

Visit `http://localhost:3000` in your browser. You should see the default Rails welcome page, indicating that your Rails application is running correctly.

### Customizing Your Tailwind Configuration

By default, Rails creates a `tailwind.config.js` file for you. This file is where you can customize your Tailwind setup. Open `tailwind.config.js` to see the configuration options.

You can add custom colors, extend the theme, and configure other settings as needed. For example, to add a custom color, you can modify the `extend` section:

```js
module.exports = {
  content: [
    './app/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        customBlue: '#1E40AF',
      },
    },
  },
  plugins: [],
}

```
Alright, hopefully everything went well. You created a new Rails project with Tailwind. This setup provides a solid foundation for building modern, responsive web applications with Rails and Tailwind. In the next section, we'll dive deeper into using Tailwind CSS within your Rails views and components.

## Creating a Home Page

Now that we have our Rails project set up with Tailwind CSS, let's create a simple home page to get things started. We'll use a Rails controller to handle the home page request and render a view.

### Step-by-Step Guide

#### 1. Generate the Controller

We'll use the Rails generator to create a new controller named `Welcome` with an action `index`. Open your terminal and run the following command:

`rails g controller welcome index`

This command does a few things:

- Creates a new controller file `welcome_controller.rb` in the `app/controllers` directory.
- Adds an `index` action to the `WelcomeController`.
- Creates a view file `index.html.erb` in the `app/views/welcome` directory.
- Updates the `config/routes.rb` file to include a route for the `index` action.

#### 2. Set the Root Route

Next, we need to set the root route of our application to point to the `index` action of the `WelcomeController`. Open the `config/routes.rb` file and update it as follows:

```ruby
Rails.application.routes.draw do
  root 'welcome#index'
end
```
This tells Rails to render the `index` view of the `WelcomeController` when someone visits the root URL of the application.

#### 3. Update the View

Now let's update the `index.html.erb` view to include some content styled with Tailwind CSS. Open the `app/views/welcome/index.html.erb` file and replace its contents with the following:

```html
<div class="min-h-screen flex items-center justify-center bg-gray-100">
  <div class="text-center">
    <h1 class="text-4xl font-bold text-gray-800">Welcome to Your Rails App with Tailwind CSS</h1>
    <p class="mt-4 text-lg text-gray-600">This is the home page of your new Rails application.</p>
  </div>
</div>
```
This simple view uses Tailwind CSS utility classes to center the content and style the text.

#### 4. Start the Rails Server

Start your Rails server if it's not running:

`./bin/dev`

Visit `http://localhost:3000` in your browser. You should see the newly created home page with the styled content. The page might be plain, but we'll add some more styling and content on the next section.

## Adding Some Styling

Now that we have a basic home page set up, let's add some styling to make it look a bit more polished. Tailwind CSS makes it easy to style your application with its utility-first approach, and there are plenty of sample templates available to help you get started.

### Using Tailwind UI

[Tailwind UI](https://tailwindui.com/) offers a collection of professionally designed, fully responsive HTML components built with Tailwind CSS. You can browse through various components and templates, pick one that suits your needs, and integrate it into your Rails application.

### Step-by-Step Guide

#### 1. Browse Tailwind UI Templates

Visit [Tailwind UI](https://tailwindui.com/) and browse through the available templates. You can find templates for various sections of a website, including headers, footers, hero sections, and more.

#### 2. Pick a Template

Once you find a template you like, click on it to view the code. Copy the HTML code provided by Tailwind UI.

#### 3. Add the Template to Your View

Open the `app/views/welcome/index.html.erb` file and replace its contents with the HTML code you copied from Tailwind UI. For example, if you chose a simple hero section, your `index.html.erb` might look like this:

```html
<div class="relative bg-white overflow-hidden">
  <div class="max-w-7xl mx-auto">
    <div class="relative z-10 pb-8 bg-white sm:pb-16 md:pb-20 lg:max-w-2xl lg:w-full lg:pb-28 xl:pb-32">
      <main class="mt-10 mx-auto max-w-7xl px-4 sm:mt-12 sm:px-6 md:mt-16 lg:mt-20 lg:px-8 xl:mt-28">
        <div class="sm:text-center lg:text-left">
          <h1 class="text-4xl tracking-tight font-extrabold text-gray-900 sm:text-5xl md:text-6xl">
            <span class="block xl:inline">Welcome to</span>
            <span class="block text-indigo-600 xl:inline">Your Rails App</span>
          </h1>
          <p class="mt-3 text-base text-gray-500 sm:mt-5 sm:text-lg sm:max-w-xl sm:mx-auto md:mt-5 md:text-xl lg:mx-0">
            This is the home page of your new Rails application.
          </p>
        </div>
      </main>
    </div>
  </div>
</div>

```
#### 4. Save and Refresh

Save the file and refresh your browser. You should see the new design applied to your home page. You should now see a more polished welcome page, but it's a little empty. Let's add a nav bar and a footer.

## Adding a Component Library

As your project grows, maintaining styles directly within your HTML using utility classes can become unwieldy. For long-term projects, it's beneficial to have a component library to make your codebase more maintainable. Component libraries provide pre-designed and pre-styled components, which can significantly speed up development and ensure consistency across your application.

### Benefits of Using a Component Library

1. **Maintainability**: Instead of applying styles to individual elements, you can use reusable components, making your code cleaner and easier to maintain.
2. **Consistency**: Component libraries ensure a consistent design language across your application.
3. **Productivity**: Pre-built components save time, allowing you to focus on building features rather than styling.

### Tailwind Component Libraries

There are several Tailwind CSS component libraries available that can help you streamline your development process:

- **DaisyUI**: A popular component library that extends Tailwind CSS with pre-designed components and themes.
- **Flowbite**: Offers a collection of UI components built with Tailwind CSS.
- **Headless UI**: Provides completely unstyled, fully accessible UI components, designed to integrate with Tailwind CSS.
- **Meraki UI**: A collection of beautiful and responsive components.

For this tutorial, we will use [**DaisyUI**](https://daisyui.com/docs/themes/) to add a component library to our Rails application.

### Adding DaisyUI to Your Project

#### 1. Install DaisyUI

To add DaisyUI to your project, you'll need to install it via npm or yarn. Run the following command in your project directory:

`yarn add daisyui`

#### 2. Configure Tailwind to Use DaisyUI

Next, you need to configure Tailwind to include DaisyUI as a plugin. Open your `tailwind.config.js` file and add `daisyui` to the plugins array:
```js
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/**/*.css'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
}

```
#### 3. Use DaisyUI Components

With DaisyUI installed and configured, you can start using its components in your views. For example, let's add a styled button to our home page. Open `app/views/welcome/index.html.erb` and update it as follows:

```html
<div class="min-h-screen flex items-center justify-center bg-gray-100">
  <div class="text-center">
    <h1 class="text-4xl font-bold text-gray-800">Welcome to Your Rails App with Tailwind CSS</h1>
    <p class="mt-4 text-lg text-gray-600">This is the home page of your new Rails application.</p>
    <button class="btn btn-primary mt-4">Get Started</button>
  </div>
</div>

```

In this example, the `btn btn-primary` classes come from DaisyUI, providing a pre-styled button.

## Wrap-up

Ok, this is getting a bit long. Let's wrap-up for now.  So far we explored what Tailwind CSS is and why it's a powerful choice for styling web applications, emphasizing its utility-first approach, customization capabilities, and responsive design features.  We created a new Rails project with Tailwind CSS integrated from the get-go, utilizing modern tools like ESBuild and Propshaft.

We walked through the installation and configuration process of Tailwind CSS, ensuring it was ready to be used in our project. We generated a new controller and set up a basic home page, styled with Tailwind CSS to give it a polished look. We integrated a design from Tailwind UI, enhancing the visual appeal of our home page with professionally designed components. We discussed the benefits of using a component library for maintainability and consistency and added DaisyUI to our project, using it to style elements.

This tutorial has covered a lot of ground, providing a solid foundation for building a polished Rails application with Tailwind CSS. To keep things manageable, I'll split this tutorial into two parts. In the next part, we'll dive deeper into more advanced features and customizations, adding more functionality and further refining our application.

Stay tuned for Part 2, where we'll continue to enhance our Rails app with more Tailwind CSS goodness and advanced techniques!
