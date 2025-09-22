defmodule TheMastermind.Interaction do
  @moduledoc """
  The Interaction context.
  """

  import Ecto.Query, warn: false
  alias TheMastermind.Repo

  alias TheMastermind.Interaction.Announcement

  @doc """
  Returns the list of announcements.

  ## Examples

      iex> list_announcements()
      [%Announcement{}, ...]

  """
  def list_announcements do
    Repo.all(Announcement)
  end

  @doc """
  Gets a single announcement.

  Raises `Ecto.NoResultsError` if the Announcement does not exist.

  ## Examples

      iex> get_announcement!(123)
      %Announcement{}

      iex> get_announcement!(456)
      ** (Ecto.NoResultsError)

  """
  def get_announcement!(id), do: Repo.get!(Announcement, id)
  def get_announcement_by_message_id!(message_id), do: Repo.get_by!(Announcement, message_id: message_id)

  @doc """
  Creates a announcement.

  ## Examples

      iex> create_announcement(%{field: value})
      {:ok, %Announcement{}}

      iex> create_announcement(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_announcement(attrs) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a announcement.

  ## Examples

      iex> update_announcement(announcement, %{field: new_value})
      {:ok, %Announcement{}}

      iex> update_announcement(announcement, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_announcement(%Announcement{} = announcement, attrs) do
    announcement
    |> Announcement.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a announcement.

  ## Examples

      iex> delete_announcement(announcement)
      {:ok, %Announcement{}}

      iex> delete_announcement(announcement)
      {:error, %Ecto.Changeset{}}

  """
  def delete_announcement(%Announcement{} = announcement) do
    Repo.delete(announcement)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking announcement changes.

  ## Examples

      iex> change_announcement(announcement)
      %Ecto.Changeset{data: %Announcement{}}

  """
  def change_announcement(%Announcement{} = announcement, attrs \\ %{}) do
    Announcement.changeset(announcement, attrs)
  end

  def submit_received_announcement(%Announcement{} = announcement, discord_id) do
    submission = %TheMastermind.Interaction.AnnouncementSubmission{announcement_id: announcement.id, discord_id: discord_id}

    submission
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:announcement, announcement)
    |> TheMastermind.Repo.insert!()
  end

  def received_announcement?(%Announcement{} = announcement, discord_id) do
    query = from s in TheMastermind.Interaction.AnnouncementSubmission, where: s.announcement_id == ^announcement.id and s.discord_id == ^discord_id

    TheMastermind.Repo.exists?(query)
  end
end
