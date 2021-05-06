defmodule Test do
  def test() do
    pid = spawn(&recv_r/0)
    :timer.send_interval(20, self(), :tick)
    test_r(pid)
  end

  def test_r(pid) do
    # Process.send_after(self(), :tick, 20)

    receive do
      :tick ->
        send(pid, :abc)
        send(pid, :abc)
        send(pid, :abc)
        send(pid, :abc)
        send(pid, :abc)
        test_r(pid)
    end
  end

  def recv_r() do
    receive do
      :x ->
        recv_r()

      _ ->
        send(self(), :x)
        recv_r()
    end
  end
end
