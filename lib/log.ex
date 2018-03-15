defmodule Log do
  require Logger

  def info(title, string), do: Logger.info fn -> format(title, string) end
  def warn(title, string), do: Logger.warn fn -> format(title, string) end
  def error(title, string), do: Logger.error fn -> format(title, string) end
  def debug(title, string), do: Logger.debug fn -> format(title, string) end

  defp format(a, b), do: "[#{a}] #{b}"
end
