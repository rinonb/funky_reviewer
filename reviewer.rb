#!/usr/bin/env ruby

# Debug information
puts "Ruby version: #{RUBY_VERSION}"
puts "Gem paths:"
Gem.paths.path.each { |path| puts "  #{path}" }

class CodeReviewer
  def self.review_changes(branch, target_branch = 'master')
    new.review_changes(branch, target_branch)
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
    AiService.call(prompt: prompt)
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
  results = CodeReviewer.review_changes('branch_name')
  puts results
end
