---
publishDate: "2015-06-05"
title: Common Ruby Design Patterns
category: Ruby
tags: [Rails, Ruby, Patterns ]
image: /images/design_patterns.jpg
---



# Unleashing the Power of Ruby on Rails Design Patterns

Ruby on Rails is beloved for its simplicity and elegance, but as applications grow, maintaining clean and manageable code can become challenging. Enter design patterns—tried and true solutions that can keep your codebase organized, testable, and maintainable. Let's lets look at some essential design patterns in Ruby on Rails that can elevate your development game.



### 1. Service Objects
**Problem**: Controllers and models become bloated with business logic.

**Solution**: Encapsulate business logic in service objects to keep controllers lean and models focused on database interactions.

**Example:**
```ruby
# app/services/user_registration_service.rb
class UserRegistrationService
  def initialize(user_params)
    @user_params = user_params
  end

  def call
    user = User.new(@user_params)
    if user.save
      send_welcome_email(user)
    else
      handle_failure(user)
    end
  end

  private

  def send_welcome_email(user)
    UserMailer.welcome_email(user).deliver_now
  end

  def handle_failure(user)
    # Handle registration failure, such as logging errors or notifying admins
  end
end

# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def create
    service = UserRegistrationService.new(user_params)
    if service.call
      redirect_to root_path, notice: 'User registered successfully'
    else
      render :new, alert: 'User registration failed'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
```

### 2. Presenters
**Problem**: Mixing presentation logic in views and models leads to cluttered code.

**Solution**: Use presenters to handle complex view logic, keeping views clean and focused.

**Example:**
```ruby
# app/presenters/user_presenter.rb
class UserPresenter
  def initialize(user)
    @user = user
  end

  def full_name
    "\#{@user.first_name} \#{@user.last_name}"
  end

  def formatted_join_date
    @user.created_at.strftime("%B %d, %Y")
  end

  def member_since
    "\#{@user.created_at.year} - \#{Time.now.year}"
  end
end

# In the view (e.g., app/views/users/show.html.erb)
<% user_presenter = UserPresenter.new(@user) %>
<p>Full Name: <%= user_presenter.full_name %></p>
<p>Join Date: <%= user_presenter.formatted_join_date %></p>
<p>Member Since: <%= user_presenter.member_since %></p>
```

### 3. Query Objects
**Problem**: Database queries are scattered throughout the application, making them hard to manage.

**Solution**: Encapsulate database queries in query objects to make them reusable and testable.

**Example**:
```ruby
# app/queries/recent_posts_query.rb
class RecentPostsQuery
  def initialize(user, relation = Post.all)
    @user = user
    @relation = relation
  end

  def call
    @relation.where(user: @user, published: true)
             .where('created_at >= ?', 30.days.ago)
  end
end

# Using the query object in the controller:
class PostsController < ApplicationController
  def index
    @posts = RecentPostsQuery.new(current_user).call
  end
end

# Using the query object in the model:
class User < ApplicationRecord
  has_many :posts

  def recent_posts
    RecentPostsQuery.new(self).call
  end
end
```

### 4. Decorators
**Problem**: Adding responsibilities directly to objects makes them bloated.

**Solution**: Use decorators to add responsibilities dynamically without modifying the original object.

**Example:**
```ruby
require 'delegate'

class Person
  attr_accessor :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  def greet
    "Hello, my name is #{@name}."
  end
end

class PersonDecorator < SimpleDelegator
  def birthday
    obj.age += 1
    "Happy birthday! You are now #{self.age} years old."
  end

  def obj
    __getobj__
  end
end

person = Person.new("Alice", 30)
decorated_person = PersonDecorator.new(person)
decorated_person.birthday

```

### 5. Form Objects
**Problem**: Handling form submissions that span multiple models can be messy.

**Solution**: Use form objects to encapsulate the form logic, making the process cleaner and more manageable.

**Example:**
```ruby
# app/forms/registration_form.rb
class RegistrationForm
  include ActiveModel::Model

  attr_accessor :user, :profile

  validates :user, presence: true
  validates :profile, presence: true

  def save
    return false unless valid?
    ActiveRecord::Base.transaction do
      @user.save!
      @profile.save!
    end
  end
end

# app/controllers/registrations_controller.rb
class RegistrationsController < ApplicationController
  def create
    @registration_form = RegistrationForm.new(user: User.new(user_params), profile: Profile.new(profile_params))

    if @registration_form.save
      redirect_to root_path, notice: 'Registration successful'
    else
      render :new, alert: 'Registration failed'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def profile_params
    params.require(:profile).permit(:bio, :avatar)
  end
end
```

### 6. Value Objects
**Problem**: Repeating logic for simple entities without identity.

**Solution**: Use value objects to encapsulate attributes and related logic, ensuring immutability and reducing duplication.

**Example:**
```ruby
# app/value_objects/money.rb
class Money
  attr_reader :amount, :currency

  def initialize(amount, currency)
    @amount = amount
    @currency = currency
  end

  def ==(other)
    amount == other.amount && currency == other.currency
  end

  def +(other)
    raise 'Currency mismatch' unless currency == other.currency
    Money.new(amount + other.amount, currency)
  end

  def to_s
    "\#{amount} \#{currency}"
  end
end

# Usage:
price = Money.new(10, 'USD')
tax = Money.new(1.5, 'USD')
total = price + tax

puts total.to_s # Output: 11.5 USD
```

### 7. Policy Objects
**Problem**: Authorization logic cluttering models and controllers.

**Solution**: Use policy objects to handle authorization, keeping your codebase organized and secure.

**Example:**
```ruby
# app/policies/post_policy.rb
class PostPolicy
  attr_reader :user, :post

  def initialize(user, post)
    @user = user
    @post = post
  end

  def edit?
    post.user == user
  end

  def delete?
    user.admin? || post.user == user
  end
end

# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]

  def edit
    authorize!(@post, :edit?)
  end

  def update
    authorize!(@post, :edit?)
    if @post.update(post_params)
      redirect_to @post, notice: 'Post updated successfully'
    else
      render :edit
    end
  end

  def destroy
    authorize!(@post, :delete?)
    @post.destroy
    redirect_to posts_path, notice: 'Post deleted successfully'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize!(resource, action)
    policy = "\#{resource.class}Policy".constantize.new(current_user, resource)
    raise 'Unauthorized' unless policy.public_send(action)
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
```

### 8. Builder
**Problem**: Constructing complex objects step-by-step leads to repetitive code.

**Solution**: Use the builder pattern to construct complex objects in a more controlled and readable manner.

**Example:**
```ruby
# app/builders/car_builder.rb
class CarBuilder
  def initialize
    @car = Car.new
  end

  def add_engine(engine)
    @car.engine = engine
    self
  end

  def add_wheels(wheels)
    @car.wheels = wheels
    self
  end

  def add_color(color)
    @car.color = color
    self
  end

  def build
    @car
  end
end

# Usage:
builder = CarBuilder.new
car = builder.add_engine('V8').add_wheels(4).add_color('Red').build

puts car.inspect
```

### 9. Interactor
**Problem**: Complex business logic scattered across the application.

**Solution**: Use interactors to encapsulate business logic in simple, reusable services.

**Example:**
```ruby
# app/interactors/create_order.rb
class CreateOrder
  include Interactor

  def call
    order = Order.create!(context.order_params)
    context.fail!(error: "Order invalid") unless order.valid?
    context.order = order
  end
end

# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  def create
    result = CreateOrder.call(order_params: order_params)

    if result.success?
      redirect_to order_path(result.order), notice: 'Order created successfully'
    else
      render :new, alert: result.error
    end
  end

  private

  def order_params
    params.require(:order).permit(:product_id, :quantity, :shipping_address)
  end
end
```

### 10. Observer
**Problem**: Scattered event-driven logic makes the codebase hard to manage.

**Solution**: Use observers to handle event-driven functionality in a clean, centralized way.

**Example:**
```ruby
# app/observers/user_observer.rb
class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.welcome_email(user).deliver_now
  end

  def after_update(user)
    UserMailer.profile_updated_email(user).deliver_now if user.profile_updated?
  end
end

# app/models/user.rb
class User < ApplicationRecord
  def profile_updated?
    saved_change_to_attribute?(:profile)
  end
end

# Configuration (e.g., in an initializer)
ActiveRecord::Base.observers = :user_observer
ActiveRecord::Base.instantiate_observers
```

### 11. Null Object
**Problem**: Constant nil checks cluttering the codebase.

**Solution**: Use null objects to provide default behavior, eliminating the need for nil checks.

**Example:**
```ruby
# app/models/null_user.rb
class NullUser
  def name
    "Guest"
  end

  def email
    "guest@example.com"
  end

  def admin?
    false
  end
end

# app/models/user.rb
class User < ApplicationRecord
  def self.find_or_guest(id)
    find(id)
  rescue ActiveRecord::RecordNotFound
    NullUser.new
  end
end

# Usage in the controller:
class UsersController < ApplicationController
  def show
    @user = User.find_or_guest(params[:id])
  end
end

# In the view (e.g., app/views/users/show.html.erb)
<p>Name: <%= @user.name %></p>
<p>Email: <%= @user.email %></p>
<p>Admin: <%= @user.admin? ? 'Yes' : 'No' %></p>
```

## Conclusion
Design patterns are powerful tools that can make your Ruby on Rails applications more maintainable, scalable, and understandable. By incorporating these patterns, you can write cleaner, more organized code and focus on building great features. Happy coding!
