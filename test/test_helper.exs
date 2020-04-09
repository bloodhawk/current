Logger.configure(level: :info)

Application.put_env(:current, Current.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL") || "ecto://postgres:postgres@localhost/current",
  pool: Ecto.Adapters.SQL.Sandbox
)

for file <- ~W{support/repo.exs support/schema.exs support/data.exs support/case.exs} do
  Code.require_file(file, __DIR__)
end

# Reset backing storage, start the repository, and run migration.
_ = Ecto.Adapters.Postgres.storage_down(Current.Test.Repo.config())
:ok = Ecto.Adapters.Postgres.storage_up(Current.Test.Repo.config())

{:ok, _} = Current.Test.Repo.start_link()
{:ok, _} = Application.ensure_all_started(:ecto_sql)

migrations = Path.join(:code.priv_dir(:current), "/repo/migrations")
migration = Path.join(migrations, "1_setup.exs")

Code.require_file(migration)

:ok = Ecto.Migrator.up(Current.Test.Repo, 0, Current.Test.Repo.Migrations.Setup, log: false)

ExUnit.configure([])
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Current.Test.Repo, :manual)
