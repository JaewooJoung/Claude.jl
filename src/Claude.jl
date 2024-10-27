module Claude

using HTTP
using JSON3
using Base.Iterators

export ClaudeClient, chat, Message, Tool, update_api_key!

# Types
struct Tool
    type::String
    name::String
    description::Union{String,Nothing}
    input_schema::Union{Dict,Nothing}
    display_width_px::Union{Int,Nothing}
    display_height_px::Union{Int,Nothing}
    display_number::Union{Int,Nothing}
end

function Tool(;
    type::Union{String,Nothing}=nothing,
    name::String,
    description::Union{String,Nothing}=nothing,
    input_schema::Union{Dict,Nothing}=nothing,
    display_width_px::Union{Int,Nothing}=nothing,
    display_height_px::Union{Int,Nothing}=nothing,
    display_number::Union{Int,Nothing}=nothing
)
    Tool(
        type === nothing ? "" : type,
        name,
        description,
        input_schema,
        display_width_px,
        display_height_px,
        display_number
    )
end

struct Message
    role::String
    content::String
end

mutable struct ClaudeClient
    api_key::String
    model::String
    max_tokens::Int
    tools::Vector{Tool}
    base_url::String
    headers::Dict{String,String}

    function ClaudeClient(;
        api_key::Union{String,Nothing}=nothing,
        model::String="claude-3-5-sonnet-20241022",
        max_tokens::Int=1024,
        tools::Vector{Tool}=Tool[],
        base_url::String="https://api.anthropic.com/v1"
    )
        if api_key === nothing
            api_key = get(ENV, "ANTHROPIC_API_KEY", "")
            if isempty(api_key)
                error("API key must be provided or set in ANTHROPIC_API_KEY environment variable")
            end
        end

        headers = Dict{String,String}(
            "content-type" => "application/json",
            "x-api-key" => api_key,
            "anthropic-version" => "2023-06-01",
            "anthropic-beta" => "computer-use-2024-10-22"
        )

        new(api_key, model, max_tokens, tools, base_url, headers)
    end
end

# Helper Functions
function tool_to_dict(tool::Tool)
    dict = Dict{String,Any}("name" => tool.name)
    
    !isempty(tool.type) && (dict["type"] = tool.type)
    tool.description !== nothing && (dict["description"] = tool.description)
    tool.input_schema !== nothing && (dict["input_schema"] = tool.input_schema)
    tool.display_width_px !== nothing && (dict["display_width_px"] = tool.display_width_px)
    tool.display_height_px !== nothing && (dict["display_height_px"] = tool.display_height_px)
    tool.display_number !== nothing && (dict["display_number"] = tool.display_number)
    
    return dict
end

function update_api_key!(client::ClaudeClient, new_key::String)
    client.api_key = new_key
    client.headers["x-api-key"] = new_key
    return client
end

# Main Functions
function chat(client::ClaudeClient, messages::Vector{Message})
    url = "$(client.base_url)/messages"
    
    body = Dict{String,Any}(
        "model" => client.model,
        "max_tokens" => client.max_tokens,
        "messages" => [Dict("role" => m.role, "content" => m.content) for m in messages]
    )
    
    if !isempty(client.tools)
        body["tools"] = [tool_to_dict(tool) for tool in client.tools]
    end

    response = HTTP.post(
        url,
        client.headers,
        JSON3.write(body)
    )

    if response.status == 200
        return JSON3.read(response.body)
    else
        error("API request failed with status $(response.status)")
    end
end

# Convenience method for single message
chat(client::ClaudeClient, message::String) = chat(client, [Message("user", message)])

end # module