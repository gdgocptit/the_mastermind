defmodule TheMastermind.Discord.Slashs.Profile do
  @behaviour Nosedrum.ApplicationCommand

  import Ecto.Query, warn: false
  import Nostrum.Struct.Embed

  alias Nostrum.Struct.ApplicationCommandInteractionDataOption

  @impl true
  def description, do: "Xem thông tin profile của một người"

  @impl true
  def type, do: :slash

  @impl true
  def command(interaction) do
    user_data = TheMastermind.Account.User |> TheMastermind.Repo.get_by(discord_id: interaction.user.id)
    user_data = case interaction.data.options do
      [%ApplicationCommandInteractionDataOption{name: "user", value: user_id}] ->
        TheMastermind.Account.User |> TheMastermind.Repo.get_by(discord_id: user_id)

      _ -> user_data
    end

    interaction |> response_interaction(user_data)
  end

  @impl true
  def options do
    [
      %{
        type: :user,
        name: "user",
        description: "User mà bạn cần xem thông tin",
        required: false
      }
    ]
  end

  def response_interaction(_interaction, nil) do
    embed = %Nostrum.Struct.Embed{}
    |> put_description("Người dùng chưa được định danh!.")
    |> put_color(0xEB4034)

    [embeds: [embed], ephemeral?: true]
  end

  def response_interaction(interaction, user_data) when is_nil(user_data) == false do
    user_data = user_data |> TheMastermind.Repo.preload(:announcement_submissions)

    user_announcement_submission_count = length(user_data.announcement_submissions || [])
    total_announcement_count = TheMastermind.Repo.one(from a in TheMastermind.Interaction.Announcement, select: count(a.id))

    {:ok, interaction_user} = Nostrum.Api.Guild.member(interaction.guild_id, user_data.discord_id)

    avatar_url = Nostrum.Struct.User.avatar_url(elem(Nostrum.Api.User.get(user_data.discord_id), 1), "png")

    response_embed = %Nostrum.Struct.Embed{}
    |> put_author("#{interaction_user.nick}", avatar_url, avatar_url)
    |> put_thumbnail(avatar_url)
    |> put_field("Tên", user_data.name, true)
    |> put_color(0xFCBA03)

    response_embed = if user_data.discord_role_id do
      response_embed |> put_field("Đội", "<@&#{user_data.discord_role_id}>", true)
    else
      response_embed
    end

    response_embed = response_embed
    |> put_field("Tỷ lệ confirm thông báo", "#{user_announcement_submission_count * 100 / total_announcement_count}%", false)
    |> put_field("Mã sinh viên", "```#{user_data.student_id}```", false)

    [embeds: [response_embed]]
  end
end
