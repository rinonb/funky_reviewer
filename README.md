# 🤓

### Getting started

Copy `.env.example` to a fresh `.env` file, update the variables accordingly.

There you're able to change the reviewing mode, which currently are 2: funky and boring, with funky being the default one naturally.

Install the gems
`bundle install`

And start copy pasting review comments like they're your own (so vibe reviewing really).

`bundle exec rackup`

Go to http://localhost:9292

#### Roadmap
- Feed more context to the review like the PR description, more of the codebase etc.
- Make it a gem that works in Rails out of the box
- Add support for more review modes
- Make the prompts configurable from the UI

---
Released under MIT License
