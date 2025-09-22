
defmodule TheMastermind.Interaction.AnnouncementSubmission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcement_submissions" do
    field :discord_id, :integer

    belongs_to :announcement, TheMastermind.Interaction.Announcement

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
