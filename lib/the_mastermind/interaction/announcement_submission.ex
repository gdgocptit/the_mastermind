
defmodule TheMastermind.Interaction.AnnouncementSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcement_submissions" do
    belongs_to :announcement, TheMastermind.Interaction.Announcement
    belongs_to :user, TheMastermind.Account.User, foreign_key: :discord_id, references: :discord_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:discord_id, :announcement_id])
    |> unique_constraint([:discord_id, :announcement_id])
    |> validate_required([:discord_id, :announcement_id])
  end
end
