defmodule DemoWeb.CoreComponents do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup")

  def flash_group(assigns) do
    ~H"""
    <div class="fixed top-2 right-2 z-50 space-y-2">
      <div
        :for={{kind, _} <- @flash}
        id={"flash-group-#{kind}"}
        class={[
          "rounded-lg p-3 text-sm font-medium shadow-lg border max-w-sm",
          kind == :info && "bg-emerald-50 text-emerald-800 border-emerald-200",
          kind == :error && "bg-rose-50 text-rose-900 border-rose-200"
        ]}
        phx-click={JS.remove_class("animate-in", to: "#flash-group-#{kind}") |> hide("#flash-group-#{kind}")}
        phx-value-key={kind}
      >
        <div class="flex items-center gap-2">
          <div class="flex-1">
            <%= Phoenix.Flash.get(@flash, kind) %>
          </div>
          <button type="button" class="group relative">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
      </div>
    </div>
    """
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-out duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end
end
