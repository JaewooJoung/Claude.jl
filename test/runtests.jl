using Test
using Claude
using HTTP
using JSON3

@testset "Claude.jl" begin
    @testset "Tool Construction" begin
        @test_nowarn Tool(name="test_tool")
        
        tool = Tool(
            type="function",
            name="complex_tool",
            description="A test tool",
            input_schema=Dict("type" => "object"),
            display_width_px=800,
            display_height_px=600,
            display_number=1
        )
        
        @test tool.type == "function"
        @test tool.name == "complex_tool"
        @test tool.description == "A test tool"
        @test tool.input_schema == Dict("type" => "object")
        @test tool.display_width_px == 800
        @test tool.display_height_px == 600
        @test tool.display_number == 1
        
        # Test default values
        simple_tool = Tool(name="simple_tool")
        @test simple_tool.type == ""
        @test simple_tool.description === nothing
        @test simple_tool.input_schema === nothing
    end

    @testset "Message Construction" begin
        msg = Message("user", "Hello")
        @test msg.role == "user"
        @test msg.content == "Hello"
    end

    @testset "ClaudeClient Construction" begin
        # Test with explicit API key
        client = ClaudeClient(api_key="test_key")
        @test client.api_key == "test_key"
        @test client.model == "claude-3-5-sonnet-20241022"
        @test client.max_tokens == 1024
        @test isempty(client.tools)
        @test client.base_url == "https://api.anthropic.com/v1"
        
        # Test headers
        @test client.headers["content-type"] == "application/json"
        @test client.headers["x-api-key"] == "test_key"
        @test client.headers["anthropic-version"] == "2023-06-01"
        @test client.headers["anthropic-beta"] == "computer-use-2024-10-22"
        
        # Test custom parameters
        custom_client = ClaudeClient(
            api_key="test_key",
            model="custom-model",
            max_tokens=2048,
            tools=[Tool(name="test_tool")],
            base_url="https://custom.url"
        )
        @test custom_client.model == "custom-model"
        @test custom_client.max_tokens == 2048
        @test length(custom_client.tools) == 1
        @test custom_client.base_url == "https://custom.url"
        
        # Test environment variable fallback
        withenv("ANTHROPIC_API_KEY" => "env_key") do
            env_client = ClaudeClient()
            @test env_client.api_key == "env_key"
        end
        
        # Test error when no API key is available
        withenv("ANTHROPIC_API_KEY" => nothing) do
            @test_throws ErrorException ClaudeClient()
        end
    end

    @testset "tool_to_dict Function" begin
        tool = Tool(
            type="function",
            name="test_tool",
            description="A test tool",
            input_schema=Dict("type" => "object"),
            display_width_px=800,
            display_height_px=600,
            display_number=1
        )
        
        dict = Claude.tool_to_dict(tool)
        @test dict["type"] == "function"
        @test dict["name"] == "test_tool"
        @test dict["description"] == "A test tool"
        @test dict["input_schema"] == Dict("type" => "object")
        @test dict["display_width_px"] == 800
        @test dict["display_height_px"] == 600
        @test dict["display_number"] == 1
        
        # Test minimal tool
        minimal_tool = Tool(name="minimal")
        minimal_dict = Claude.tool_to_dict(minimal_tool)
        @test keys(minimal_dict) == Set(["name"])
    end

    @testset "update_api_key! Function" begin
        client = ClaudeClient(api_key="old_key")
        update_api_key!(client, "new_key")
        @test client.api_key == "new_key"
        @test client.headers["x-api-key"] == "new_key"
    end

    @testset "chat Function" begin
        # Mock HTTP response
        mock_response = """
        {
            "id": "msg_123",
            "type": "message",
            "role": "assistant",
            "content": "Hello!",
            "model": "claude-3-5-sonnet-20241022",
            "stop_reason": "end_turn",
            "usage": {
                "input_tokens": 10,
                "output_tokens": 20
            }
        }
        """
        
        # Test single message chat
        HTTP.post(url, headers, body) = HTTP.Response(200, mock_response)
        client = ClaudeClient(api_key="test_key")
        
        response = chat(client, "Hello")
        @test response.type == "message"
        @test response.role == "assistant"
        @test response.content == "Hello!"
        
        # Test multiple messages chat
        messages = [
            Message("user", "Hello"),
            Message("assistant", "Hi"),
            Message("user", "How are you?")
        ]
        response = chat(client, messages)
        @test response.type == "message"
        @test response.role == "assistant"
        
        # Test error handling
        HTTP.post(url, headers, body) = HTTP.Response(400, "Bad Request")
        @test_throws ErrorException chat(client, "Hello")
    end
end