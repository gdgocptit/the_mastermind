defmodule TheMastermind.Repo.Migrations.CreateAnnouncementSubmissions do
  use Ecto.Migration

  def change do
    create table(:announcement_submissions) do
      add :discord_id, :bigint
      add :announcement_id, references(:announcements, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:announcement_submissions, [:announcement_id, :discord_id])
  end
end
