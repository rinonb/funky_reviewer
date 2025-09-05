class AiService
  def self.call(prompt:, temperature: 0.5)
    new(prompt, temperature).call
  end

  def initialize(prompt, temperature)
    @prompt = prompt
    @temperature = temperature
  end

  def call
    response = client.chat(
      parameters: {
        model: 'gpt-4-turbo-preview',
        messages: [
          {
            role: 'system',
            content: system_prompt
          },
          { role: 'user', content: @prompt }
        ],
        temperature: @temperature
      }
    )

    response.dig('choices', 0, 'message', 'content')
  end

  private

  def client
    @client ||= OpenAI::Client.new(
      access_token: ENV.fetch('OPENAI_API_KEY') { raise 'OPENAI_API_KEY environment variable is not set' }
    )
  end

  def system_prompt
    <<~PROMPT
      You are a thorough code reviewer. Provide comprehensive feedback that helps improve code quality,
      maintainability, and reliability. Be specific and actionable in your suggestions.
    PROMPT
  end
end
