defmodule PcaWeb.AsyncLive.Index do
  use PcaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(%{count: 0})}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("add_count_async", _params, socket) do
    {:noreply, socket |> start_async(:add_count, fn -> :timer.sleep(1000) end)}
  end

  @impl true
  def handle_event("cancel_add_count", _params, socket) do
    {:noreply, socket |> cancel_async(:add_count)}
  end

  @impl true
  def handle_async(:add_count, {:ok, _} = result, socket) do
    IO.inspect(result, label: "handle_async add_count")

    {:noreply, socket |> update(:count, &(&1 + 1))}
  end

  @impl true
  def handle_async(:add_count, {:exit, _} = result, socket) do
    # Expected: cancel_async emit this function
    # Actual: cancel_async do not emit this function
    IO.inspect(result, label: "handle_async add_count")

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      Count: <%= @count %>
    </div>
    <div>
      <button phx-click="add_count_async">[Add count async]</button>
    </div>
    <div>
      <button phx-click="cancel_add_count">[Cancel add count]</button>
    </div>
    """
  end
end
