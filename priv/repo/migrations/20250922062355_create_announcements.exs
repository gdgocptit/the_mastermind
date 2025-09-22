defmodule TheMastermind.Repo.Migrations.CreateAnnouncements do
  use Ecto.Migration

  def change do
    create table(:announcements) do
      add :message_id, :bigint

      timestamps(type: :utc_datetime)
    end

    create unique_index(:announcements, [:message_id])
  end
end
