# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

bp3-string adapts `String` for BP3 (persuavis/black_phoebe_3), a multi-site multi-tenant Rails
application. It adds `String#modelize` and `String#controllerize`, which turn table-like names into the
model and controller class names the application actually has, including namespaced and STI models that
`classify` gets wrong.

## Commands

The gems run on Ruby 3.4.6 (`.ruby-version`). Prefix commands with `~/.rvm/bin/rvm 3.4.6 do` when the
shell is not already on it; a missing `rspec` means the wrong Ruby, not a missing bundle.

- `bundle exec rake` - specs and RuboCop (the default task)
- `bundle exec rspec spec/path/to/file_spec.rb[:LINE]` - one file or example
- `bundle exec rubocop` / `bundle exec rubocop -a`
- `bin/setup`, `bin/console`, `rake install`

## Architecture

- **Modelize** / **Controllerize**: look the string up in `TableModelMap.hash` / `TableControllerMap.hash`,
  falling back to `classify` / `"#{classify.pluralize}Controller"`
- **MapperBase**: shared base of the two maps. `hash` returns `cached_hash`; `testing?` (false) makes
  `cached_hash` rebuild on every call when overridden
- **TableModelMap**: from `ActiveRecord::Base.descendants`, maps each table name (schema prefix dropped)
  and its singular to a model name. An STI subclass maps to its base class; a non-STI class with
  descendants maps to its first descendant
- **TableControllerMap**: maps table names to `"#{Model.pluralize}Controller"` (STI subclasses under their
  own tableized name), then adds leaf `ActionController::Base` descendants without overriding the model
  entries
- **Subclassable**: `sti_subclass?`, `sti_model?` (has a `type` column), `subclassed?`
- Both maps build lazily behind a mutex. The Railtie includes the two modules in `String` in an
  `after_initialize` block and resets both caches in `to_prepare`, so they rebuild after a code reload

The maps are only as complete as the loaded classes, so they need eager loading or a reset after it. The
application subclasses both maps (`app/services/table_model_map.rb`, `table_controller_map.rb`), and its
`Structure` concern resets `TableModelMap`.

## Testing

`lib/bp3/string/test.rb` is an ActiveRecord model (`bp3_string_tests`) for the specs; it is not required
by the gem. The specs define models and controllers inline and include the modules in `String` themselves.

## Code Style

- RuboCop (`.rubocop.yml`): target Ruby 3.2.2, NewCops, rubocop-rake and rubocop-rspec; AbcSize 26,
  MethodLength 15, BlockLength 66, ModuleLength 150; `Lint/ConstantDefinitionInBlock` and `Lint/Void`
  are off for `lib/bp3/**/railtie.rb`, where classes are reopened inside a block
- Every file starts with `# frozen_string_literal: true`
- American English; no trailing whitespace on any added or modified line

## Release

Bump `lib/bp3/string/version.rb` and add a `CHANGELOG.md` entry. `rake release` tags, pushes and
publishes to rubygems.org; leave releasing and committing to the user.
