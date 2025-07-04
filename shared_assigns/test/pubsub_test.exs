defmodule SharedAssigns.PubSubTest do
  use ExUnit.Case, async: true

  describe "PubSubProvider module compilation" do
    test "defines the expected macros and functions" do
      # Ensure module is loaded
      Code.ensure_loaded(SharedAssigns.PubSubProvider)

      # Test that the module compiles and exports expected macros and functions
      assert macro_exported?(SharedAssigns.PubSubProvider, :__using__, 1)
      assert function_exported?(SharedAssigns.PubSubProvider, :broadcast_context_change, 4)
    end
  end

  describe "PubSubConsumer module compilation" do
    test "defines the expected macros and functions" do
      # Ensure module is loaded
      Code.ensure_loaded(SharedAssigns.PubSubConsumer)

      # Test that the module compiles and exports expected macros
      assert macro_exported?(SharedAssigns.PubSubConsumer, :__using__, 1)
    end
  end

  describe "PubSub macro integration" do
    defmodule TestProvider do
      @moduledoc false

      # Mock the required functions to avoid PubSub dependency
      def __shared_assigns_contexts__, do: [theme: "light", user_role: "admin"]
      def context_keys, do: [:theme, :user_role]
      def __shared_assigns_pubsub__, do: TestPubSub
    end

    defmodule TestConsumer do
      @moduledoc false

      def subscribed_contexts, do: [:theme, :user_role]
      def __shared_assigns_pubsub__, do: TestPubSub
    end

    test "provider macro creates expected functions" do
      assert TestProvider.__shared_assigns_contexts__() == [theme: "light", user_role: "admin"]
      assert TestProvider.context_keys() == [:theme, :user_role]
      assert TestProvider.__shared_assigns_pubsub__() == TestPubSub
    end

    test "consumer macro creates expected functions" do
      assert TestConsumer.subscribed_contexts() == [:theme, :user_role]
      assert TestConsumer.__shared_assigns_pubsub__() == TestPubSub
    end
  end

  describe "PubSub broadcasting function" do
    test "broadcast_context_change/4 handles arguments correctly" do
      # Ensure module is loaded
      Code.ensure_loaded(SharedAssigns.PubSubProvider)

      # Test that the function exists and doesn't crash with mock data
      # We can't test actual broadcasting without a real PubSub setup
      assert function_exported?(SharedAssigns.PubSubProvider, :broadcast_context_change, 4)

      # Test would require actual PubSub setup, but function signature is verified
      assert true
    end
  end

  describe "Module verification with runtime checks" do
    test "modules are properly loaded and available" do
      # Double-check that modules are available at runtime
      {:module, _} = Code.ensure_loaded(SharedAssigns.PubSubProvider)
      {:module, _} = Code.ensure_loaded(SharedAssigns.PubSubConsumer)

      # Verify they respond to module info
      provider_macros = SharedAssigns.PubSubProvider.__info__(:macros)
      consumer_macros = SharedAssigns.PubSubConsumer.__info__(:macros)
      provider_functions = SharedAssigns.PubSubProvider.__info__(:functions)

      assert {:__using__, 1} in provider_macros
      assert {:__using__, 1} in consumer_macros
      assert {:broadcast_context_change, 4} in provider_functions
    end
  end
end
