defmodule TheMastermind.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :student_id, :string
    field :discord_id, :integer
    field :discord_role_id, :integer

    has_many :announcement_submissions, TheMastermind.Interaction.AnnouncementSubmission,
      foreign_key: :discord_id,
      references: :discord_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :student_id, :discord_id, :discord_role_id])
    |> validate_required([:name, :student_id])
  end
end
