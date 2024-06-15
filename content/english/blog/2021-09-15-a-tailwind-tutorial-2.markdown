---
publishDate: "2021-09-15"
title: Tailwind in Rails - 2
tags: [Rails, JavaScript, Tutorials]

toc: true
toc_label: 'Tailwind'

image: /images/tailwind.jpg
  #

excerpt: Part 2 of the tailwind tutorial!. Let's add some DaisyUI components and add a light/dark mode functionality to the app!
---

Welcome back! This is part 2 of my tailwind tutorial. Part 1 focused on setting up the basic structure of your application by adding tailwind and Daisy.
In this tutorial, we'll go through the process of enhancing your Ruby on Rails application with modern and responsive UI components. By the end, you'll add some tailwind components to make the application more polished. We'll also add a light/dark feature!  So, let's dive in 😃

# Adding a Navbar

Ok, we'll start by adding a navbar using Daisy.

**Create the Navbar Component:** Create a new partial for the navbar. In your `app/views/layouts` directory, create a file named `_navbar.html.erb` and add the following code:

```html
<nav class="navbar bg-base-100">
  <div class="flex-1">
    <a class="btn btn-ghost normal-case text-xl" href="/">Tailwind App</a>
  </div>
  <div class="flex-none">
    <ul class="menu menu-horizontal px-1" data-controller="theme-selector">
      <li><a href="/">Welcome</a></li>
      <li><a href="/about">About</a></li>
      <li><a href="/contact">Contact Us</a></li>
    </ul>
  </div>
</nav>
```


**Include the Navbar in the Application Layout:** Open your `app/views/layouts/application.html.erb` file and include the navbar partial by adding this line right before the yield statement:

    `<%= render 'layouts/navbar' %>`


With these steps, you've successfully added a navbar to your Rails application using Daisy UI. Easy!

# Adding a Footer

Now let's add the footer. It's just as easy as adding the navbar.

**Create the Footer Component:** Create a new partial for the footer. In your `app/views/layouts` directory, create a file named `_footer.html.erb` and add the following code:

```html
  <footer class="footer p-10 bg-base-200 text-base-content">
    <div>
      <span class="footer-title">Services</span>
      <a class="link link-hover" href="#">Branding</a>
      <a class="link link-hover" href="#">Design</a>
      <a class="link link-hover" href="#">Marketing</a>
      <a class="link link-hover" href="#">Advertisement</a>
    </div>
    <div>
      <span class="footer-title">Company</span>
      <a class="link link-hover" href="#">About us</a>
      <a class="link link-hover" href="#">Contact</a>
      <a class="link link-hover" href="#">Jobs</a>
      <a class="link link-hover" href="#">Press kit</a>
    </div>
    <div>
      <span class="footer-title">Legal</span>
      <a class="link link-hover" href="#">Terms of use</a>
      <a class="link link-hover" href="#">Privacy policy</a>
      <a class="link link-hover" href="#">Cookie policy</a>
    </div>
  </footer>
  ```

**Include the Footer in the Application Layout:** Open your `app/views/layouts/application.html.erb` file and include the footer partial by adding this line after the yield statement:

    `<%= render 'layouts/footer' %>`


With these steps, you've successfully added a footer to your Rails application.

# Adding a Hero Section
Ok, now for a hero section.

**Create the Hero Section:** Open your `app/views/welcome/index.html.erb` file and add the following code for the hero section:

```html
  <section class="hero min-h-screen bg-base-200">
  <div class="hero-content text-center">
    <div class="max-w-md">
      <h1 class="text-5xl font-bold">Welcome to Tailwind App</h1>
      <p class="py-6">This is a simple Rails application styled with Tailwind CSS and enhanced with Daisy UI components. Explore our features and learn more about what we offer.</p>
      <a href="/about" class="btn btn-primary">Learn More</a>
    </div>
  </div>
</section>
```

If you haven't already, go to your terminal an start your rails app to checkout the changes you've made. It it should look more polished and it was that easy!

```sh
cd ~/path-to-your-project
./bin/dev
```
Alright, up to this point you have added a footer, navbar, and a hero page. Now let's implement that light/dark feature.
# Night Mode

### Adding Themes to Rails

Adding a night mode to your application can improve user experience by providing a more comfortable viewing option in low-light environments. We'll use a Stimulus controller called `theme_selector_controller` to implement this feature. We'll add a list element to the header to select the theme using JavaScript and cookies. We'll then wrap the whole html body with a content tag so Daisy can switch the theme.

```js
module.exports = {
  content: [
    './app/**/*.{html,js,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
  daisyui: {
    themes: ["light", "dark"],
  },
}

```
Check out the Daisy UI [docs](https://daisyui.com/docs/themes/) to explore the various themes available.


### Add the Theme Toggle to the Navbar

Update the navbar to include a toggle for the night mode. In the `app/views/layouts/_navbar.html.erb` file, we add a list element that displays the current theme and toggles it when clicked.
```html
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
      <li><a href="/contact">Contact Us</a></li>
      <li>
      <!-- Add the following line 👇 -->
      <%= link_to current_theme, "#", "data-theme": current_theme, "data-action": "click->theme-selector#change" %>
      </li>
```
The `data-controller="theme-selector"` attribute connects to the Stimulus controller, and the `data-action="click->theme-selector#change"` attribute binds the click event to the `change` method in the controller.

### Create the Theme Selector Controller


Next, we create a new Stimulus controller to handle theme changes by running the following command:

`rails generate stimulus theme_selector`.

In the generated controller file,`app/javascript/controllers/theme_selector_controller.js`, we define the `change` method, which toggles between light and dark themes. This method stores the selected theme in a cookie and updates the HTML element’s `data-theme` attribute.

```js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-selector"
export default class extends Controller {
  change(event) {
    // prevents any side effects.
    event.preventDefault();
    // Gets the value of the element that was clicked.
    let theme = event.srcElement.innerHTML;

    // toggles between dark and light
    theme = theme === 'dark' ? 'light' : 'dark'
    // sets the theme using cookie, so we can pass it to the view.
    document.cookie = `theme=${theme}`;

    // set the new theme for the html element
    event.srcElement.innerHTML = theme;
    // sets 'data-theme' for the whole html document
    document.documentElement.setAttribute('data-theme', theme);
  }
}

```
### Add content_tag to the Application Layout

To enable Daisy to change the theme dynamically, we need to add a `content_tag` to the `layouts/application.html.erb` file. Daisy UI uses the `html` tag to set the theme, so we'll wrap the content of the layout with a `content_tag` that includes the `data-theme` attribute.

1. **Open the Application Layout:** Open the `app/views/layouts/application.html.erb` file.

2. **Add the `content_tag`:** Modify the content the `content_tag` with the `data-theme` attribute. Your updated layout should look like this:



```html
  <html>
  <!- Add this line 👇 ->
  <%= content_tag :html, "data-theme": cookies[:theme] do %>
    <head>
      <title>Tailwind</title>
      <meta name="viewport" content="width=device-width,initial-scale=1">
      <%= csrf_meta_tags %>
      <%= csp_meta_tag %>

      <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
      <%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>
    </head>
    <body>
      <%= render 'layouts/nav_bar' %>
      <%= yield %>
      <%= render 'layouts/footer' %>
    </body>
  <!- 👇 also this one  ->
    <% end %>
  </html>
  ```
By wrapping the `html` content with a `content_tag`, Daisy can now dynamically change the theme based on the `data-theme` attribute. Now, test out the setup! You might have to restart your server for the code additions to work.

### Custom Themes

Creating custom themes with Daisy allows you to personalize the look and feel of your application to match your brand or design preferences. Daisy provides an easy way to customize themes through the Tailwind CSS configuration.Daisy also has a [theme generator](https://daisyui.com/theme-generator/) you can use.

1. **Configure Custom Themes in Tailwind Config:** Open your `tailwind.config.js` file and add your custom themes under the `daisyui` section. Here, you can define different themes with specific colors and settings.

```js
module.exports = {
  content: [
    './app/**/*.{html,js,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('daisyui'),
  ],
  daisyui: {
    themes: [
      {
        mytheme: {
          "primary":   "#a991f7",
          "secondary": "#f6d860",
          "accent":    "#37cdbe",
          "neutral":   "#3d4451",
          "base-100":  "#ffffff",
          "info":      "#2094f3",
          "success":   "#009485",
          "warning":   "#ff9900",
          "error":     "#ff5724",
        },
      },
      "light",
      "dark",
    ],
  },
}
```

- **Quick Note** In this example, a custom theme named `mytheme` is defined with specific color values for primary, secondary, accent, and other color categories. You can customize these values to match your desired theme.

- **Apply Custom Themes:** To use your custom theme, you can set the `data-theme` attribute on the `html` tag to the name of your theme. This can be done dynamically using the `content_tag` method in your `layouts/application.html.erb` file, as shown in the previous section.

- **Switching Between Themes:** To allow users to switch between themes, you can use the theme selector we implemented earlier. Update the theme names in the controller to include your custom theme.

- **Update the Helper:** Ensure your helper methods support the new themes. Open your `app/helpers/application_helper.rb` file and update it with the following code:

```ruby
module ApplicationHelper
  def current_theme
    cookies[:theme] = 'mytheme' if cookies[:theme]&.empty?
    cookies[:theme]
  end
end
```

- **Apply Custom Themes:** To use your custom theme, you can set the `data-theme` attribute on the `html` tag to the name of your theme. This can be done dynamically using the `content_tag` method in your `layouts/application.html.erb` file, as shown in the previous section.

- **Switching Between Themes:** To allow users to switch between themes, you can use the theme selector we implemented earlier. Update the theme names in the controller to include your custom theme.

```js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme-selector"
export default class extends Controller {
  change(event) {
    event.preventDefault();
    let theme = event.srcElement.innerHTML;

    theme = theme === 'dark' ? 'mytheme' : theme === 'mytheme' ? 'light' : 'dark'
    document.cookie = `theme=${theme}`;

    event.srcElement.innerHTML = theme;
    document.documentElement.setAttribute('data-theme', theme);
  }
}
```
By defining custom themes in the Tailwind config and allowing users to switch between them, you can create a personalized and dynamic user experience. Custom themes enable you to tailor the visual aspects of your application to better align with your brand identity and user preferences


## Adding Blog Posts

To make your Rails application more dynamic and content-rich, you can add a blog feature. This section will guide you through creating a simple blog system with Rails, allowing users to create, read, update, and delete blog posts.

- **Generate the Blog Post Model and Controller:** Use the Rails generator to create a `BlogPost` model and controller. Run the following command in your terminal:

`rails generate scaffold BlogPost title:string content:text`

This command will create the necessary files for the BlogPost model, database migrations, and controller actions.

- **Run Migrations**: After generating the scaffold, run the migrations to update your database schema:

`rails db:migrate`

- **Set Up Routes**: Ensure the routes for the blog posts are set up in your config/routes.rb file:

```ruby
Rails.application.routes.draw do
  resources :blog_posts
  # Other routes...
end
```
- **Customize the Views**: Customize the views for the blog posts to match the design of your application. You can find the views in the app/views/blog_posts/ directory. For example, you can update the index.html.erb to display a list of blog posts with links to show, edit, and delete each post.

```html
<!-- app/views/blog_posts/index.html.erb -->
<h1>Blog Posts</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @blog_posts.each do |blog_post| %>
      <tr>
        <td><%= blog_post.title %></td>
        <td><%= link_to 'Show', blog_post %></td>
        <td><%= link_to 'Edit', edit_blog_post_path(blog_post) %></td>
        <td><%= link_to 'Destroy', blog_post, method: :delete, data: { confirm: 'Are you sure?' } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Blog Post', new_blog_post_path %>
```

- **Styling with Daisy UI:** Use Daisy UI components to style your blog post views. For example, you can use Daisy UI classes to style the blog post index page:

```html
<!-- app/views/blog_posts/index.html.erb -->
<h1 class="text-3xl font-bold mb-4">Blog Posts</h1>

<table class="table w-full">
  <thead>
    <tr>
      <th>Title</th>
      <th colspan="3">Actions</th>
    </tr>
  </thead>

  <tbody>
    <% @blog_posts.each do |blog_post| %>
      <tr>
        <td><%= blog_post.title %></td>
        <td><%= link_to 'Show', blog_post, class: 'btn btn-primary' %></td>
        <td><%= link_to 'Edit', edit_blog_post_path(blog_post), class: 'btn btn-secondary' %></td>
        <td><%= link_to 'Destroy', blog_post, method: :delete, data: { confirm: 'Are you sure?' }, class: 'btn btn-error' %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to 'New Blog Post', new_blog_post_path, class: 'btn btn-success' %>
```

- **Add a Link to the Navbar:** Finally, add a link to the blog posts in your navbar so users can easily navigate to the blog section. Update the `app/views/layouts/_navbar.html.erb` file:

```html
<nav class="navbar bg-base-100">
  <div class="flex-1">
    <a class="btn btn-ghost normal-case text-xl" href="/">Tailwind App</a>
  </div>
  <div class="flex-none">
    <ul class="menu menu-horizontal px-1" data-controller="theme-selector">
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
      <li><a href="/contact">Contact Us</a></li>
      <li><a href="/blog_posts">Blog</a></li>
      <li><%= link_to current_theme, "#", "data-theme": current_theme, "data-action": "click->theme-selector#change" %></li>
    </ul>
  </div>
</nav>

```
