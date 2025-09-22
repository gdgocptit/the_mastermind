defmodule TheMastermind.Interaction.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcements" do
    field :message_id, :integer

    has_many :submissions, TheMastermind.Interaction.AnnouncementSubmission

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:message_id])
    |> validate_required([:message_id])
  end
end
