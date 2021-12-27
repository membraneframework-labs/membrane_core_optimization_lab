alias BareGenServer.Sink
alias BareGenServer.Filter
alias BareGenServer.Source

n = 30

{:ok, sink} = Sink.start_link()

first_filter =
  1..(n - 2)
  |> Enum.reduce(sink, fn _i, pid ->
    {:ok, filter} = Filter.start_link(pid)
    filter
  end)

{:ok, source} = Source.start_link(first_filter)

GenServer.cast(source, :start)

receive do
  {:message_type, value} ->
    value
end
