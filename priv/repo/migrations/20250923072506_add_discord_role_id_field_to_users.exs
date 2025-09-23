defmodule TheMastermind.Repo.Migrations.AddDiscordRoleIdFieldToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :discord_role_id, :bigint, null: true
    end
  end
end
