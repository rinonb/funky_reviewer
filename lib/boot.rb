require "bundler/setup"
Bundler.require

require "dotenv/load"

require_relative 'services/ai_service'
require_relative 'prompts'
require_relative 'code_reviewer'
require_relative 'app'
