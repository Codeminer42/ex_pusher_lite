defmodule ExPusherLite.Repo do
  use Ecto.Repo, otp_app: :ex_pusher_lite
  use Scrivener, page_size: 30
  @dialyzer {:nowarn_function, rollback: 1}
end
