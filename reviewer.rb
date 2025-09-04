#!/usr/bin/env ruby

# Debug information
puts "Ruby version: #{RUBY_VERSION}"
puts "Gem paths:"
Gem.paths.path.each { |path| puts "  #{path}" }

require 'openai'
require 'git'
require 'dotenv'
require 'json'

Dotenv.load

class CodeReviewer
  def initialize
    access_token = ENV.fetch('OPENAI_API_KEY') { raise 'OPENAI_API_KEY environment variable is not set' }
    @client = OpenAI::Client.new(access_token:)
  end

  def review_changes(branch, target_branch = 'master')
    @repo = Git.open('.')
    changes = get_changes(branch, target_branch)
    results = {}

    changes.each do |file, file_data|
      results[file] = review_file(file, file_data)
    end

    results
  end

  private

  def get_changes(branch, target_branch)
    changes = {}
    diff = @repo.diff("#{target_branch}...#{branch}")

    diff.each do |patch|
      file = patch.path
      begin
        content = File.read(file)
      rescue StandardError
        content = nil
      end

      changes[file] = {
        diff: patch.patch,
        content: content
      }
    end

    changes
  end

  def review_file(file, file_data)
    diff = file_data[:diff]
    content = file_data[:content]

    prompt = <<~PROMPT
      #{reviewer_prompt}

      Here is the full file, but review only the changes:
      ```ruby
      #{content}
      ```

      Here are the changes:
      ```diff
      #{diff}
      ```
    PROMPT

    puts "Reviewing file: #{file}"
    response = @client.chat(
      parameters: {
        model: 'gpt-4-turbo-preview',
        messages: [
          {
            role: 'system',
            content: 'You are a thorough code reviewer. Provide comprehensive feedback that helps improve code quality, maintainability, and reliability. Be specific and actionable in your suggestions.'
          },
          { role: 'user', content: prompt }
        ],
        temperature: 0.5
      }
    )

    response.dig('choices', 0, 'message', 'content')
  end

  def reviewer_prompt
    case ENV['REVIEWER_MODE']
    when 'funky'
      Prompts.funky
    when 'boring'
      Prompts.boring
    else
      raise "Unknown REVIEWER_MODE: #{ENV['REVIEWER_MODE']}"
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  reviewer = CodeReviewer.new
  results = reviewer.review_changes('branch_name')
  puts results
end
