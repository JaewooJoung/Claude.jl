using Claude

# Create a client with environment API key
client = ClaudeClient(
    api_key=get(ENV, "ANTHROPIC_API_KEY", ""),
    model="claude-3-5-sonnet-20241022",
    max_tokens=1024
)

# Function to print response content nicely
function print_response(resp)
    println("\nResponse Content:")
    println("----------------")
    println(resp.content[1].text)
    println("\nMetadata:")
    println("----------------")
    println("Model: ", resp.model)
    println("Tokens Used: ", resp.usage.output_tokens)
end

# Check API health first
println("Checking API health...")

# API health check function
function check_api_health(client)
    resp = chat(client, "Hello!")
    println("✓ API is working")
    println("✓ Model: ", resp.model)
    println("✓ Message ID: ", resp.id)
end

# Error handling function
function handle_error(e)
    msg = string(e)
    if occursin("credit balance", msg)
        println("⚠️ Credit balance too low")
    elseif occursin("API key", msg)
        println("⚠️ API key issue")
    else
        println("⚠️ Error: ", e)
    end
end

# Main execution flow
try
    check_api_health(client)
    println("\nAsking your question...")
    resp = chat(client, "Give me a Joke of the day ")
    print_response(resp)
catch e
    handle_error(e)
end
