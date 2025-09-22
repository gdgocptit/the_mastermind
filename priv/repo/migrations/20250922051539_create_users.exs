defmodule TheMastermind.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :student_id, :string
      add :discord_id, :bigint

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:student_id])
    create unique_index(:users, [:discord_id])
  end
end
