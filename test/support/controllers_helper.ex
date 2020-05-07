defmodule MongoosePushWeb.Support.ControllersHelper do
  def flat_request() do
    %{
      "service" => "apns",
      "body" => "A message from someone",
      "title" => "Notification title",
      "badge" => 7,
      "click_action" => ".SomeApp.Handler.action",
      "tag" => "info",
      "topic" => "com.someapp",
      "data" => %{
        "custom" => "data fields",
        "some_id" => 345_645_332,
        "nested" => %{"fields" => "allowed"}
      },
      "mode" => "prod"
    }
  end

  def alert_request() do
    %{
      "service" => "apns",
      "mode" => "prod",
      "priority" => "normal",
      "time_to_live" => 3600,
      "mutable_content" => false,
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "alert" => %{
        "body" => "A message from someone",
        "title" => "Notification title",
        "badge" => 7,
        "click_action" => ".SomeApp.Handler.action",
        "tag" => "info",
        "sound" => "standard.mp3"
      }
    }
  end

  def silent_request() do
    %{
      "service" => "apns",
      "mode" => "prod",
      "priority" => "normal",
      "time_to_live" => 3600,
      "mutable_content" => false,
      "tags" => ["some", "tags", "for", "pool", "selection"],
      "topic" => "com.someapp",
      "data" => %{
        "custom" => "data fields",
        "some_id" => 345_645_332,
        "nested" => %{"fields" => "allowed"}
      }
    }
  end

  def no_schemas_provided_response() do
    %{
      "errors" => [
        %{
          "message" => "Failed to cast value to one of: [] (no schemas provided)",
          "source" => %{"pointer" => "/"},
          "title" => "Invalid value"
        }
      ]
    }
  end

  def missing_field_response(field) do
    %{
      "errors" => [
        %{
          "message" => "Missing field: #{field}",
          "source" => %{"pointer" => "/#{field}"},
          "title" => "Invalid value"
        }
      ]
    }
  end

  def invalid_field_response(expected, received, field) do
    %{
      "errors" => [
        %{
          "message" => "Invalid #{expected}. Got: #{received}",
          "source" => %{"pointer" => "/#{field}"},
          "title" => "Invalid value"
        }
      ]
    }
  end

  def unexpected_field_response(field) do
    %{
      "errors" => [
        %{
          "message" => "Unexpected field: #{field}",
          "source" => %{"pointer" => "/#{field}"},
          "title" => "Invalid value"
        }
      ]
    }
  end

  def invalid_value_for_enum(field) do
    %{
      "errors" => [
        %{
          "message" => "Invalid value for enum",
          "source" => %{"pointer" => "/#{field}"},
          "title" => "Invalid value"
        }
      ]
    }
  end
end
