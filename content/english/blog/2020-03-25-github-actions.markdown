---
publishDate: "2020-03-25"
title: Creating a GitHub Actions Workflow
category: GitHub
tags: [tutorial]
header:
  image: /images/github-actions.jpg
---

GitHub Actions is a feature that allows you to automate tasks and workflows right within your GitHub repositories. It lets you build, test, and deploy your code projects seamlessly.

With Actions, you can create custom workflows that trigger automatically based on events like code pushes, pull requests, or scheduled times. These workflows can run scripts or commands to handle all sorts of tasks.

For example, you could set up a workflow to run your tests every time new code is pushed. Or, you could configure a workflow to build and deploy your application to a server after merging a pull request.

Actions make it simple to automate repetitive tasks and streamline your development processes. You no longer have to manually run commands or scripts. Just set up your workflows, and GitHub will take care of the rest.

In this tutorial, we'll be adding SimpleCov, RuboCop-Rails, and Brakeman as GitHub Actions to help streamline your Ruby on Rails development process. All the code for this tutorial can be found on my [repo](https://github.com/tacit7/github-actions).

## Create your project

1. Create a new repo on GitHub. You can do this by going to your GitHub repo page and clicking on "Create New".
2. On your machine, create a new rails project.

```shell
rails new github-actions # create rails project
cd github-actions # change directory
git add . # add all files to the first commit
git commit -m "initial commit" # add remote on github
git remote add origin git@github.com:<your-user-name>/github-actions.git
git push -u origin main`
```
## Scaffolding

1. Add some scaffolds so you get some tests and prepare the database.
2. Comment out the following line in the `config/assets/manifest.js` file as it breaks the workflow.
  `//= link_tree ../../../vendor/javascript .js`

3. Push to your repo

```shell
  rails generate scaffold post name:string title:string content:text
  rails generate scaffold
  user first_name:string last_name:string
  rails db:prepare
  git add . && git commit -m "add some scaffolds" && git push

```

## Running Tests Using GitHub Actions

1. Go to the github actions page.
2. There should be an "actions" tab on your repo, click on that.
3. Right underneath "Get started with GitHub Actions", click on "Set up a workflow yourself."
4. Add [this](https://github.com/tacit7/github-actions/blob/c0305cbc9e26cf989d3e2121247871888c791765/.github/workflows/main.yml) content to the online editor and commit it.

Note that the file uses `actions/checkout@v4` to check out the code, `ruby/setup-ruby@v4` to set up Ruby, and `borales/actions-yarn@v4` to install Yarn.

There is a services section for PostgreSQL. It uses the `16-alpine` PostgreSQL image, which is a lightweight image of PostgreSQL. It also uses the trust auth method, so a user/password won't have to be created. Before the tests are run, make sure that `db:prepare` is run. It has to be run with the `DATABASE_URL` and `RAILS_MASTER_KEY` environment variables.

If all goes well, the action should run the scaffolded tests when you commit your changes to the repo.

## SimpleCov

Now let's add SimpleCov. to get the necessary files that SimpleCov creates, we will use `actions/upload-artifact@v3`.

1. Add SimpleCov to your test gem group in your gemfile.
2. In the `test_helper.rb`, add the following at the very top:
   ```ruby
   require 'simplecov'
   SimpleCov.start 'rails'
   ```
3. Comment out the following line from the test helper as it gets in the way of SimpleCov: `parallelize(workers: :number_of_processors)`

4. In the `.github/workflows/main.yml`, add the following to the end of the file:
   ```yaml
   - name: Create Coverage Artifact
     uses: actions/upload-artifact@v2
       with:
        name: code-coverage
        path: coverage/
   ```
5. Do a bundle install, commit, and push.

   ```shell
   bundle install
   git commit -m "add SimpleCov to the project."
   git push
   ```

6. When the test action runs, you will now be able to download the code-coverage artifact to see the coverage of the rails project.

## Brakeman

Next, let's add Brakeman. There are a few actions on the GitHub Marketplace, but they are not very good. So, we are going to install the gem ourselves and run it using YAML's `run`. We'll also be using `tj-actions/changed-files@v44` to get the files changed in a PR or push to the main branch. We use a comma to separate the files because that is the format that Brakeman expects when testing specific files.

Add [this](https://github.com/tacit7/github-actions/commit/79296868f67a68c4cfee919edcfe21ae75c14c72) code to `main.yaml`. You can take a look at the whole file [here](https://github.com/tacit7/github-actions/blob/79296868f67a68c4cfee919edcfe21ae75c14c72/.github/workflows/main.yml). Run the action and test it by committing some vulnerabilities to the codebase. Take a look at Brakeman's [warning types](https://brakemanscanner.org/docs/warning_types/) to get an idea of what Brakeman checks for.

## rubocop-rails

Now, let's add rubocop-rails. We are going to use the same techniques as before, so there shouldn't be anything new here.

1. Create a `.rubocop.yml` file in the root directory and add the following line:

```yaml
require:
  - rubocop-rails
```

2. Make changes to your `main.yaml` so that it looks like [this](https://github.com/tacit7/github-actions/commit/f821f7263511622fbf032d134fddc1e6e2be0559). As you can see, we are using `tj-actions/changed-files@v44`, `ruby/setup-ruby@v1`, and `actions/checkout@v4`. Nothing new. The magic happens at line 79, where we pass the changed files to RuboCop. This passes only the changed files on your PR or push to RuboCop, which then lints those files.

## Things to Consider

Here are some additional things to consider when working with GitHub Actions:

1. **Caching Dependencies**: To speed up your workflows, you can cache dependencies like Ruby gems, npm packages, or system libraries. This way, they don't need to be downloaded and installed on every run.
2. **Environments and Secrets**: GitHub Actions allows you to create and manage environments and secrets for your workflows. This can be useful for storing sensitive information like API keys, passwords, or other credentials.
3. **Self-Hosted Runners**: While GitHub provides hosted runners for running your workflows, you can also set up self-hosted runners on your own infrastructure. This can be beneficial if you have specific hardware or software requirements or need to run your workflows in a more secure environment.
4. **Reusable Workflows**: Instead of duplicating workflows across multiple repositories, you can create reusable workflows that can be shared and used by other repositories in your organization or the broader GitHub community.
5. **Monitoring and Reporting**: Consider integrating your GitHub Actions workflows with monitoring and reporting tools to track their performance, identify bottlenecks, and receive notifications for failures or other issues.

Here are some useful GitHub Actions and resources you might want to read:

- [GitHub Action for Yarn](https://github.com/marketplace/actions/github-action-for-yarn)
- [Setup Ruby, JRuby, and TruffleRuby](https://github.com/marketplace/actions/setup-ruby-jruby-and-truffleruby)
- [Upload Artifact](https://github.com/marketplace/actions/upload-artifact)
- [Brakeman Linter in Action](https://github.com/marketplace/actions/brakeman-linter-in-action)

GitHub Actions is a powerful tool, and there are many ways to customize and extend it to fit your specific needs. Continuous exploration and learning can help you get the most out of it.
